//
//  SRDefaultStoriesDataStorage.swift
//  
//
//  Created by Aleksei Cherepanov on 19.05.2022.
//

import Foundation
import UIKit

final class SRDefaultStoriesDataStorage: SRStoriesDataStorage {
    let storySdk: StorySDK
    var stories: [SRStory] = []
    var groupInfo: HeaderInfo {
        didSet { onUpdateHeader?(groupInfo) }
    }
    
    var configuration: SRConfiguration { storySdk.configuration }
    var numberOfItems: Int { stories.count }
    var onReloadData: (() -> Void)?
    var dismiss: (() -> Void)?
    var onErrorReceived: ((Error) -> Void)?
    var onUpdateHeader: ((HeaderInfo) -> Void)? {
        didSet { onUpdateHeader?(groupInfo) }
    }
    private(set) var group: StoryGroup?
    weak var progress: SRProgressController? {
        didSet { progress?.activeColor = configuration.progressColor }
    }
    weak var analytics: SRAnalyticsController?
    weak var widgetResponder: SRWidgetResponder?
    
    init(sdk: StorySDK = .shared) {
        self.storySdk = sdk
        self.groupInfo = .init(isHidden: !sdk.configuration.needShowTitle)
    }
    
    func loadStories(group: StoryGroup) {
        self.group = group
        groupInfo.title = group.title
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
                self?.dismiss?()
            }
        }
    }
    
    func setupCell(_ cell: SRStoryCell, index: Int) {
        guard index < stories.count else { return }
        let story = stories[index]
        guard let data = story.storyData else { return }
        cell.needShowTitle = storySdk.configuration.needShowTitle
        
        if let background = data.background {
            setupBackground(cell, background: background)
        }
        
        for widget in data.widgets {
            let view = SRWidgetConstructor.makeWidget(widget, story: story, sdk: storySdk)
            storySdk.userDefaults
                .reaction(widgetId: widget.id)
                .map { view.setupWidget(reaction: $0) }
            (view as? SRInteractiveWidgetView)?.delegate = widgetResponder
            let position = SRWidgetConstructor.calcWidgetPosition(widget, story: story)
            cell.appendWidget(view, position: position)
        }
    }
    
    func storyId(atIndex index: Int) -> String? {
        index < stories.count ? stories[index].id : nil
    }
    
    private func setupBackground(_ cell: SRStoryCell, background: SRColor) {
        switch background {
        case .color(let color):
            cell.backgroundColors = [color, color]
        case .gradient(let array):
            cell.backgroundColors = array
        case .image(let url):
            let size = UIScreen.main.bounds.size
            let scale = UIScreen.main.scale
            let task = storySdk.imageLoader
                .load(url, size: size, scale: scale, contentMode: .scaleAspectFill) { [weak cell, weak self] result in
                    switch result {
                    case .success(let image): cell?.backgroundImage = image
                    case .failure(let error): self?.onErrorReceived?(error)
                    }
                }
            cell.cancellables.append(task)
        }
    }
    
    private func updateStories(_ stories: [SRStory]) {
        self.stories = stories
            .filter { $0.storyData != nil }
            .sorted(by: { $0.position < $1.position })
        guard !stories.isEmpty else {
            dismiss?()
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
