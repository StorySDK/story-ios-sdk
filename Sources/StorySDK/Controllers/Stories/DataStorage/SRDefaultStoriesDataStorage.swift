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
    
    var configuration: SRConfiguration { storySdk.configuration }
    var numberOfItems: Int { stories.count }
    var onReloadData: (() -> Void)?
    var onErrorReceived: ((Error) -> Void)?
    weak var progressController: SRProgressController? {
        didSet { progressController?.activeColor = configuration.progressColor }
    }
    weak var widgetResponder: SRWidgetResponder?
    
    init(sdk: StorySDK = .shared) {
        self.storySdk = sdk
    }
    
    func loadStories(group: StoryGroup) {
        widgetResponder?.group = group
        storySdk.getStories(group) { [weak self] result in
            switch result {
            case .success(let stories):
                self?.updateStories(stories)
            case .failure(let error):
                self?.onErrorReceived?(error)
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
            (view as? SRInteractiveWidgetView)?.delegate = widgetResponder
            let position = SRWidgetConstructor.calcWidgetPosition(widget, story: story)
            cell.appendWidget(view, position: position)
        }
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
            task.map { cell.cancellables.append($0) }
        }
    }
    
    private func updateStories(_ stories: [SRStory]) {
        self.stories = stories
            .filter { $0.storyData != nil }
            .sorted(by: { $0.position < $1.position })
        progressController?.numberOfItems = numberOfItems
        onReloadData?()
    }
}
