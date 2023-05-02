//
//  SRDefaultStoriesDataStorage.swift
//  
//
//  Created by Aleksei Cherepanov on 19.05.2022.
//

import Foundation
import UIKit
import Combine

final class SRDefaultStoriesDataStorage: SRStoriesDataStorage {
    var onFilled: ((Bool) -> Void)?
    
    let storySdk: StorySDK
    var stories: [SRStory] = []
    var groupInfo: HeaderInfo {
        didSet { onUpdateHeader?(groupInfo) }
    }
    
    var configuration: SRConfiguration { storySdk.configuration }
    var numberOfItems: Int { stories.count }
    var onReloadData: (() -> Void)?
    var onGotEmptyGroup: (() -> Void)?
    var onErrorReceived: ((Error) -> Void)?
    var onUpdateHeader: ((HeaderInfo) -> Void)? {
        didSet { onUpdateHeader?(groupInfo) }
    }
    private(set) var group: SRStoryGroup?
    weak var progress: SRProgressController? {
        didSet { progress?.activeColor = configuration.progressColor }
    }
    weak var analytics: SRAnalyticsController?
    weak var widgetResponder: SRWidgetResponder?
    weak var gestureRecognizer: SRStoriesGestureRecognizer?
    
    init(sdk: StorySDK = .shared) {
        self.storySdk = sdk
        self.groupInfo = .init(isHidden: !sdk.configuration.needShowTitle)
    }
    
    func loadStories(group: SRStoryGroup) {
        self.group = group
        groupInfo.title = group.title
        groupInfo.isProhibitToClose = group.settings?.isProhibitToClose ?? false
        groupInfo.isProgressHidden = group.settings?.isProgressHidden ?? false
        
        if let url = group.imageUrl {
            let height = SRGroupHeaderView.Size.image
            storySdk.imageLoader.load(
                url,
                size: CGSize(width: height, height: height)
            ) { [weak self] result in
                guard case .success(let image) = result else { return }
                self?.groupInfo.icon = image
            }
        }
        storySdk.getStories(group) { [weak self] result in
            switch result {
            case .success(let stories):
                self?.updateStories(stories)
            case .failure(let error):
                self?.onErrorReceived?(error)
                self?.onGotEmptyGroup?()
            }
        }
    }
    
    func setupCell(_ cell: SRStoryCell, index: Int) {
        guard index < stories.count else { return }
        let story = stories[index]
        guard let data = story.storyData else { return }
        cell.needShowTitle = storySdk.configuration.needShowTitle
        
        let group = DispatchGroup()
        if let background = data.background {
            group.enter()
            setupBackground(cell, background: background) { group.leave() }
        }
        
        for widget in data.widgets {
            let view = SRWidgetConstructor.makeWidget(widget, story: story, sdk: storySdk)
            group.enter()
            view.loadData({ group.leave() })?.store(in: &cell.cancellables)
            storySdk.userDefaults
                .reaction(widgetId: widget.id)
                .map { view.setupWidget(reaction: $0) }
            (view as? SRInteractiveWidgetView)?.delegate = widgetResponder
            switch view {
            case let swipeUp as SRSwipeUpView:
                let gesture = SRSwipeUpGestureRecognizer(
                    widget: swipeUp.swipeUpWidget,
                    target: gestureRecognizer
                )
                swipeUp.addGestureRecognizer(gesture)
            case let talkAbout as SRTalkAboutView:
                talkAbout.addTapGesture()
            default:
                break
            }
            let position = SRWidgetConstructor.calcWidgetPosition(widget, story: story)
            cell.appendWidget(view, position: position)
        }
        let id = story.id
        cell.isLoading = true
        group.notify(queue: .main) { [weak progress, weak cell] in
            progress?.isLoading[id] = true
            cell?.isLoading = false
        }
    }
    
    func willDisplay(_ cell: SRStoryCell, index: Int) {
        guard let id = storyId(atIndex: index) else { return }
        if progress?.isLoading[id] ?? false { return }
        progress?.isLoading[id] = false
    }
    
    func endDisplaying(_ cell: SRStoryCell, index: Int) {
        guard let id = storyId(atIndex: index) else { return }
        progress?.isLoading[id] = nil
    }
    
    func storyId(atIndex index: Int) -> String? {
        index < stories.count ? stories[index].id : nil
    }
    
    private func setupBackground(_ cell: SRStoryCell, background: BRColor, completion: @escaping () -> Void) {
        switch background {
        case .color(let color, let isFilled):
            onFilled?(isFilled)
            cell.backgroundColors = [color, color]
            completion()
        case .gradient(let array, let isFilled):
            onFilled?(isFilled)
            cell.backgroundColors = array
            completion()
        case .image(let url, let isFilled):
            onFilled?(isFilled)
            let size = UIScreen.main.bounds.size
            let scale = UIScreen.main.scale
            storySdk.imageLoader
                .load(url, size: size, scale: scale, contentMode: .scaleAspectFill) { [weak cell, weak self] result in
                    defer { completion() }
                    switch result {
                    case .success(let image): cell?.backgroundImage = image
                    case .failure(let error): self?.onErrorReceived?(error)
                    }
                }
                .store(in: &cell.cancellables)
        }
    }
    
    private func updateStories(_ stories: [SRStory]) {
        self.stories = stories
            .filter { $0.storyData != nil }
            .filter { $0.storyData?.status == .active }
            .filter { $0.layerData != nil }
            .filter { $0.layerData?.isDefaultLayer == true }
            .sorted(by: { $0.position < $1.position })
        guard numberOfItems > 0 else {
            onGotEmptyGroup?()
            return
        }
        progress?.numberOfItems = numberOfItems
        onReloadData?()
        updateStoryDuration()
    }
    
    private func updateStoryDuration() {
        let duration = TimeInterval(numberOfItems) * storySdk.configuration.storyDuration
        groupInfo.duration = Self.durationFormatter.string(from: duration)
    }
    
    private static let durationFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.unitsStyle = .abbreviated
        return f
    }()
}
