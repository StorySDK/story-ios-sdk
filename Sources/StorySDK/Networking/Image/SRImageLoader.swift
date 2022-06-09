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
    private let cache = DefaultImageCache()
    private let session = URLSession(configuration: .default,
                                     delegate: nil,
                                     delegateQueue: .main)
    private let gifQueue = DispatchQueue(label: "\(packageBundleId).gifQueue",
                                         qos: .userInitiated)
    public init() {}
    
    @discardableResult
    public func load(_ url: URL,
                     size: CGSize,
                     scale: CGFloat = 1,
                     contentMode: UIView.ContentMode = .scaleAspectFill,
                     completion: @escaping (Result<UIImage, Error>) -> Void) -> Cancellable? {
        let cacheKey = url.absoluteString
        if let cancelable = cache.loadImage(
            cacheKey,
            size: size,
            scale: scale,
            contentMode: contentMode,
            completion: { image in
                if let image = image {
                    completion(.success(image))
                } else {
                    completion(.failure(SRError.unknownError))
                }
            }
        ) {
            return cancelable
        }
        let task = session.dataTask(with: url) { [weak cache] data, response, error in
            if let data = data, let image = UIImage(data: data) {
                cache?.saveImage(cacheKey, image: image)
                let result = image.scale(to: size, scale: scale, mode: contentMode)
                completion(.success(result))
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(SRError.unknownError))
            }
        }
        task.resume()
        return task
    }
    
    @discardableResult
    func loadGif(_ url: URL,
                 size: CGSize,
                 completion: @escaping (Result<UIImage, Error>) -> Void) -> Cancellable? {
        let task = session.dataTask(with: url) { [weak gifQueue] data, _, error in
            if let data = data, let queue = gifQueue {
                queue.async {
                    let options = [String(kCGImageSourceShouldCache): kCFBooleanFalse] as CFDictionary
                    guard let source = CGImageSourceCreateWithData(data as CFData, options) else {
                        DispatchQueue.main.async { completion(.failure(SRError.unknownError)) }
                        return
                    }
                    var images = [UIImage]()
                    let imageCount = CGImageSourceGetCount(source)
                    var totalDuration: TimeInterval = 0
                    for i in 0..<imageCount {
                        guard let image = CGImageSourceCreateImageAtIndex(source, i, options) else { continue }
                        images.append(UIImage(cgImage: image))
                        totalDuration += source.delay(for: i)
                    }
                    guard let image = UIImage.animatedImage(with: images, duration: totalDuration) else {
                        DispatchQueue.main.async { completion(.failure(SRError.unknownError)) }
                        return
                    }
                    DispatchQueue.main.async { completion(.success(image)) }
                }
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

private extension CGImageSource {
    func delay(for index: Int) -> TimeInterval {
        var delay: TimeInterval = 0.1
        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(self, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        if CFDictionaryGetValueIfPresent(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque(), gifPropertiesPointer) == false {
            return delay
        }
        
        let gifProperties: CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
        
        // Get delay time
        var delayObject = unsafeBitCast(
            CFDictionaryGetValue(
                gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()
            ),
            to: AnyObject.self
        )
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(
                CFDictionaryGetValue(
                    gifProperties,
                    Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()),
                to: AnyObject.self
            )
        }
        
        delay = delayObject as? TimeInterval ?? 0
        return max(0.1, delay)
    }
}
