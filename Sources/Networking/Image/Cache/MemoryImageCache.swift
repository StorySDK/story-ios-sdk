//
//  MemoryImageCache.swift
//  
//
//  Created by Aleksei Cherepanov on 13.05.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

final class MemoryImageCache: ImageCache {
    let cache = NSCache<NSString, StoryImage>()
    
    /// NSCache based image cache
    /// - Parameter limit: Cache size limit in Mb. 125 Mb by default
    init(limit: Int = 125_000) {
        cache.totalCostLimit = limit
    }
    
    func hasImage(_ key: String) -> Bool {
        cache.object(forKey: .init(string: key)) != nil
    }
    func loadImage(_ key: String) -> StoryImage? {
        cache.object(forKey: .init(string: key))
    }
    func saveImage(_ key: String, image: StoryImage) {
        cache.setObject(image, forKey: .init(string: key), cost: image.cacheCost)
    }
    func removeImage(_ key: String) {
        cache.removeObject(forKey: .init(string: key))
    }
    func removeAll() {
        cache.removeAllObjects()
    }
}

private extension StoryImage {
    var cacheCost: Int {
        if let data = pngImageData() { return data.count }
        // Aproximate size
        return Int(size.width * size.height * 4)
    }
}
