//
//  SRImageLoader.swift
//  
//
//  Created by Aleksei Cherepanov on 13.05.2022.
//

import Foundation
import Combine
import UIKit

public class SRImageLoader {
    private let cache: ImageCache
    private let session = URLSession(configuration: .default,
                                     delegate: nil,
                                     delegateQueue: .main)
    
    public init(cache: ImageCache) {
        self.cache = cache
    }
    
    public func load(_ url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) -> Cancellable? {
        let cacheKey = url.absoluteString
        if let image = cache.loadImage(cacheKey) {
            completion(.success(image))
            return nil
        }
        let task = session.dataTask(with: url) { [weak cache] data, response, error in
            if let data = data, let image = UIImage(data: data) {
                cache?.saveImage(cacheKey, image: image)
                completion(.success(image))
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
