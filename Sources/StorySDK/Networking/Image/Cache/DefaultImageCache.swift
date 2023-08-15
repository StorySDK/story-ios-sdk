//
//  DefaultImageCache.swift
//  
//
//  Created by Aleksei Cherepanov on 19.05.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif
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
        contentMode: StoryContentMode = StoryViewContentMode.scaleAspectFill
    ) async -> StoryImage? {
        guard let cache = fullSizeCache, cache.hasImage(key) else { return nil }
        guard let result = cache.loadImage(key) else { return nil }
        return await withCheckedContinuation { continuation in
            let image = result.scale(to: size, scale: scale, mode: contentMode)
            continuation.resume(returning: image)
        }
    }
    
    func saveImage(_ key: String, image: StoryImage) {
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
