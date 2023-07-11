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
    private var preloaded: [String: Bool] = [:]
    
    private var firstWidgetUrlsToLoad: [URL] = [URL]()
    private var otherWidgetUrlsToLoad: [URL] = [URL]()
    
    init(sdk: StorySDK = .shared, stories: [SRStory]) {
        self.storySdk = sdk
        self.stories = stories
    }
    
    func isPreloadRequired() -> Bool {
        var firstWidget = true
        
        for story in stories {
            preloaded[story.id] = false
            
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
        
        if firstWidgetUrlsToLoad.count > 0 || otherWidgetUrlsToLoad.count > 0 {
            return true
        } else {
            for key in preloaded.keys {
                preloaded[key] = true
            }
            return false
        }
    }
    
    func preload(completion: @escaping (Bool) -> Void) {
        load(urls: firstWidgetUrlsToLoad, otherUrls: otherWidgetUrlsToLoad, completion: completion)
    }
    
    private func load(urls: [URL], otherUrls: [URL], completion: @escaping (Bool) -> Void) {
        let size = UIScreen.main.bounds.size
        let scale = UIScreen.main.scale
        
        guard urls.count > 0 else {
            completion(true)
            
            additionalLoad(urls: otherUrls, completion: completion)
            return
        }
        
        let number = urls.count
        var index = 0
        
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
                
                index += 1
                
                if index == number {
                    completion(true)
                    self?.additionalLoad(urls: otherUrls, completion: completion)
                }
            }
        }
    }
    
    private func additionalLoad(urls: [URL], completion: @escaping (Bool) -> Void) {
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
                    print("Additional loaded: \(itemUrl)")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}
