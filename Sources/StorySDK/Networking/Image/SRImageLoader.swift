//
//  SRImageLoader.swift
//  
//
//  Created by Aleksei Cherepanov on 13.05.2022.
//

import Foundation
#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif
import Combine

public typealias SRImageLoaderTask = Task<StoryImage, Error>

public class SRImageLoader {
    private let cache: DefaultImageCache
    private let session = URLSession(configuration: .default,
                                     delegate: nil,
                                     delegateQueue: .main)
    init(logger: SRLogger) {
        cache = DefaultImageCache(logger: logger)
    }
    
    @discardableResult
    public func load(_ url: URL,
                     size: CGSize,
                     scale: CGFloat = 1,
                     contentMode: StoryContentMode = StoryViewContentMode.scaleAspectFill,
                     completion: @escaping (Result<StoryImage?, Error>) -> Void) -> Cancellable {
        Task {
            do {
                let image = try await load(url, size: size, scale: scale, contentMode: contentMode)
                DispatchQueue.main.async { completion(.success(image)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }
    
    public func load(_ url: URL,
                     size: CGSize,
                     scale: CGFloat = 1,
                     contentMode: StoryContentMode = StoryViewContentMode.scaleAspectFill) async throws -> StoryImage? {
        let cacheKey = url.absoluteString
        if let image = await cache.loadImage(
            cacheKey,
            size: size,
            scale: scale,
            contentMode: contentMode
        ) {
            print("Has cache for \(cacheKey)")
            return image
        }
        
        // try to find local resource in bundle
        if let shaHash = url.absoluteString.data(using: .utf8)?.sha256().hex() {
            if let path = Bundle.main.path(forResource: shaHash, ofType: "webp") {
                if let localImage = StoryImage(contentsOfFile: path) {
                    return localImage.scale(to: size, scale: scale, mode: contentMode)
                }
            } else {
                print("cached image not found")
            }
        }
        
        let image: StoryImage? = try await withCheckedThrowingContinuation { continuation in
            let task = session.dataTask(with: url) { data, response, error in
                if let data = data {
                    if let image = StoryImage(data: data) {
                        continuation.resume(returning: image)
                    } else {
                        continuation.resume(returning: nil)
                    }
                    //continuation.resume(returning: image)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: SRError.unknownError)
                }
            }
            task.resume()
        }
        try Task.checkCancellation()
        if let image = image {
            cache.saveImage(cacheKey, image: image)
            return image.scale(to: size, scale: scale, mode: contentMode)
        } else {
            return nil
        }
    }
    
    @discardableResult
    func loadGif(_ url: URL,
                 size: CGSize,
                 completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable? {
        let task = session.dataTask(with: url) { data, _, error in
            if let data = data {
                completion(.success(data))
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(SRError.unknownError))
            }
        }
        task.resume()
        return task
    }
}

class BlankCancellable: Cancellable {
    func cancel() {}
}

extension URLSessionDataTask: Cancellable {}
extension Task: Cancellable {}
