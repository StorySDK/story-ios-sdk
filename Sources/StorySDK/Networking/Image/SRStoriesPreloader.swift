//
//  SRStoriesPreloader.swift
//  StorySDK
//
//  Created by Ingvarr Alef on 07.07.2023.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public class SRStoriesPreloader {
    let storySdk: StorySDK
    
    private var stories: [SRStory]
    private let defaultStorySize: CGSize
    
    private var preloaded: [String: Bool] = [:]
    
    private var firstWidgetUrlsToLoad: [URL] = [URL]()
    private var otherWidgetUrlsToLoad: [URL] = [URL]()
    
    private var videosUrlsToLoad: [URL] = [URL]()
    
    init(sdk: StorySDK = .shared, stories: [SRStory], defaultStorySize: CGSize) {
        self.storySdk = sdk
        self.stories = stories
        self.defaultStorySize = defaultStorySize
    }
    
    func isPreloadRequired() -> Bool {
        var firstWidget = true
        
        for story in stories {
            preloaded[story.id] = false
            
            if let data = story.storyData {
                switch data.background {
                case .video(let url, _):
                    videosUrlsToLoad.append(url)
                default:
                    break
                }
                
                for widget in data.widgets {
                    logger.debug(widget.id.description)
                    let widgetData = SRWidgetConstructor.makeWidget(widget, story: story, defaultStorySize: defaultStorySize, sdk: storySdk)
                    
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
        
        if firstWidgetUrlsToLoad.count > 0 ||
            otherWidgetUrlsToLoad.count > 0 ||
            videosUrlsToLoad.count > 0 {
            return true
        } else {
            for key in preloaded.keys {
                preloaded[key] = true
            }
            return false
        }
    }
    
    func preload(completion: @escaping (Bool) -> Void) {
        load(urls: firstWidgetUrlsToLoad,
             otherUrls: otherWidgetUrlsToLoad,
             videoUrls: videosUrlsToLoad,
             completion: completion)
    }
    
    private func load(urls: [URL], otherUrls: [URL], videoUrls: [URL],
                      completion: @escaping (Bool) -> Void) {
        let size = StoryScreen.screenBounds.size
        let scale = StoryScreen.screenScale
        
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
                    logger.debug(itemUrl.absoluteString, logger: .imageCache)
                case .failure(let error):
                    logger.error(error.localizedDescription, logger: .imageCache)
                }
                
                index += 1
                
                if index == number {
                    completion(true)
                    self?.additionalLoad(urls: otherUrls, completion: completion)
                }
            }
        }
        
        for videoUrl in videoUrls {
            downloadVideo(from: videoUrl) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let savedURL):
                        logger.debug("Video saved to: \(savedURL.path)", logger: .imageCache)
                    case .failure(let error):
                        logger.error("Error downloading video: \(error)", logger: .imageCache)
                    }
                }
            }
            
            completion(true)
        }
    }
    
    func downloadVideo(from url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { temporaryFileLocation, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let temporaryFileLocation = temporaryFileLocation else {
                completion(.failure(NSError(domain: "DownloadError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Temporary file location is nil."])))
                return
            }
            
            do {
                let fileManager = FileManager.default
                let cacheDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                
                var mp4File: String = url.lastPathComponent
                if let shaHash = url.absoluteString.data(using: .utf8)?.sha256().hex() {
                    mp4File = shaHash + ".mp4"
                }
                
                let savedURL = cacheDirectory.appendingPathComponent(mp4File) //(url.lastPathComponent)
                
                if fileManager.fileExists(atPath: savedURL.path) {
                    completion(.success(savedURL))
                    
                    return
                }
                
                try fileManager.moveItem(at: temporaryFileLocation, to: savedURL)
                completion(.success(savedURL))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }

    
    
    private func additionalLoad(urls: [URL], completion: @escaping (Bool) -> Void) {
        let size = StoryScreen.screenBounds.size
        let scale = StoryScreen.screenScale
        
        for itemUrl in urls {
            storySdk.imageLoader.load(
                itemUrl,
                size: size,
                scale: scale
            ) { [weak self] result in
                switch result {
                case .success(let image):
                    logger.debug("Additional loaded: \(itemUrl)")
                case .failure(let error):
                    logger.error(error)
                }
            }
        }
    }
}
