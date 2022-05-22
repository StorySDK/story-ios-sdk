//
//  MemoryImageCache.swift
//  
//
//  Created by Aleksei Cherepanov on 13.05.2022.
//

import UIKit

final class MemoryImageCache: ImageCache {
    let cache = NSCache<NSString, UIImage>()
    
    /// NSCache based image cache
    /// - Parameter limit: Cache size limit in Mb. 125 Mb by default
    init(limit: Int = 125_000) {
        cache.totalCostLimit = limit
    }
    
    func hasImage(_ key: String) -> Bool {
        cache.object(forKey: .init(string: key)) != nil
    }
    func loadImage(_ key: String) -> UIImage? {
        cache.object(forKey: .init(string: key))
    }
    func saveImage(_ key: String, image: UIImage) {
        cache.setObject(image, forKey: .init(string: key), cost: image.cacheCost)
    }
    func removeImage(_ key: String) {
        cache.removeObject(forKey: .init(string: key))
    }
    func removeAll() {
        cache.removeAllObjects()
    }
}

private extension UIImage {
    var cacheCost: Int {
        if let data = pngData() { return data.count }
        // Aproximate size
        return Int(size.width * size.height * 4)
    }
}
