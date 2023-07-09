//
//  SRStoriesPreloader.swift
//  StorySDK
//
//  Created by Ingvarr Alef on 07.07.2023.
//

import UIKit

public class SRStoriesPreloader {
    let storySdk: StorySDK
    
    private var stories: [SRStory]
    
    init(sdk: StorySDK = .shared, stories: [SRStory]) {
        self.storySdk = sdk
        self.stories = stories
    }
    
    func preload() {
        var firstWidgetUrlsToLoad: [URL] = [URL]()
        var otherWidgetUrlsToLoad: [URL] = [URL]()
        var firstWidget = true
        
        for story in stories {
            if let data = story.storyData {
                for widget in data.widgets {
                    print(widget.id.description)
                    let widgetData = SRWidgetConstructor.makeWidget(widget, story: story, sdk: storySdk)
                    
                    if let imageWidget = widgetData as? SRImageWidgetView {
                        if let url = imageWidget.url {
                            if firstWidget {
                                firstWidgetUrlsToLoad.append(url)
                            } else {
                                otherWidgetUrlsToLoad.append(url)
                            }
                        }
                    }
                }
            }
            
            firstWidget = false
        }
        
        load(urls: firstWidgetUrlsToLoad, otherUrls: otherWidgetUrlsToLoad)
    }
    
    private func load(urls: [URL], otherUrls: [URL]) {
        let size = UIScreen.main.bounds.size
        let scale = UIScreen.main.scale
        
        guard urls.count > 0 else {
            additionalLoad(urls: otherUrls)
            return
        }
        
        for itemUrl in urls {
            storySdk.imageLoader.load(
                itemUrl,
                size: size,
                scale: scale
            ) { [weak self] result in
                
                switch result {
                case .success(let image):
                    print(itemUrl)
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
                self?.additionalLoad(urls: otherUrls)
            }
        }
    }
    
    private func additionalLoad(urls: [URL]) {
        let size = UIScreen.main.bounds.size
        let scale = UIScreen.main.scale
        
        for itemUrl in urls {
            storySdk.imageLoader.load(
                itemUrl,
                size: size,
                scale: scale
            ) { [weak self] result in
                switch result {
                case .success(let image):
                    print(itemUrl)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}
