//
//  SRImageLoader.swift
//  
//
//  Created by Aleksei Cherepanov on 13.05.2022.
//

import Foundation
import UIKit
import Combine

public typealias SRImageLoaderTask = Task<UIImage, Error>

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
                     contentMode: UIView.ContentMode = .scaleAspectFill,
                     completion: @escaping (Result<UIImage?, Error>) -> Void) -> Cancellable {
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
                     contentMode: UIView.ContentMode = .scaleAspectFill) async throws -> UIImage? {
        let cacheKey = url.absoluteString
        if let image = await cache.loadImage(
            cacheKey,
            size: size,
            scale: scale,
            contentMode: contentMode
        ) { return image }
        let image: UIImage? = try await withCheckedThrowingContinuation { continuation in
            let task = session.dataTask(with: url) { data, response, error in
                if let data = data {
                    if let image = UIImage(data: data) {
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
        
//        cache.saveImage(cacheKey, image: image)
//        return image.scale(to: size, scale: scale, mode: contentMode)
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
