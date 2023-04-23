//
//  DefaultImageCache.swift
//  
//
//  Created by Aleksei Cherepanov on 19.05.2022.
//

import UIKit
import Combine

final class DefaultImageCache {
    let queue = OperationQueue()
    
    let fullSizeCache: ImageCache?
//    let resizedCache: ImageCache = MemoryImageCache()
    
    init(logger: SRLogger) {
        do {
            fullSizeCache = try DiskImageCache(logger: logger)
        } catch {
            logger.error(error.localizedDescription, logger: .imageCache)
            fullSizeCache = nil
        }
    }
    
    @discardableResult
    func loadImage(
        _ key: String,
        size: CGSize,
        scale: CGFloat = 1,
        contentMode: UIView.ContentMode = .scaleAspectFill
    ) async -> UIImage? {
        guard let cache = fullSizeCache, cache.hasImage(key) else { return nil }
        guard let result = cache.loadImage(key) else { return nil }
        return await withCheckedContinuation { continuation in
            let image = result.scale(to: size, scale: scale, mode: contentMode)
            continuation.resume(returning: image)
        }
    }
    
    func saveImage(_ key: String, image: UIImage) {
        fullSizeCache?.saveImage(key, image: image)
    }
    
    func removeImage(_ key: String) {
        fullSizeCache?.removeImage(key)
    }
    
    func removeAll() {
        fullSizeCache?.removeAll()
        // resizedCache.removeAll()
    }
}

import AVFoundation

extension UIImage {
    func scale(to size: CGSize, scale: CGFloat = 1, mode: UIView.ContentMode = .scaleAspectFill) -> UIImage {
        var rect = CGRect(x: 0, y: 0, width: max(1, size.width), height: max(1, size.height))
        switch mode {
        case .scaleAspectFit:
            let newSize = AVMakeRect(aspectRatio: self.size, insideRect: rect).size
            rect = .init(origin: .zero, size: newSize)
        case .scaleAspectFill:
            let newRect = AVMakeRect(aspectRatio: rect.size, insideRect: .init(origin: .zero, size: self.size))
            let multiplier = size.height / newRect.height
            rect = .init(
                x: 0, // -newRect.origin.x * multiplier,
                y: 0, // -newRect.origin.y * multiplier,
                width: self.size.width * multiplier,
                height: self.size.height * multiplier
            )
        default:
            break // Scale to fill by default
        }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { _ in
            draw(in: rect)
        }
    }
}