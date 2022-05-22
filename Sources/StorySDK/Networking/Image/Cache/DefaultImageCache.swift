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
    
    let fullSizeCache: ImageCache? = try? DiskImageCache()
//    let resizedCache: ImageCache = MemoryImageCache()
    
    @discardableResult
    func loadImage(
        _ key: String,
        size: CGSize,
        scale: CGFloat = 1,
        contentMode: UIView.ContentMode = .scaleAspectFill,
        completion: @escaping (UIImage?) -> Void
    ) -> Cancellable? {
//        let resizedKey = key + "_\(Int(size.width))x\(Int(size.height))_\(Int(scale))_\(contentMode.rawValue)"
//        if let image = resizedCache.loadImage(resizedKey) {
//            completion(image)
//            return nil
//        }
        guard let cache = fullSizeCache, cache.hasImage(key) else { return nil }
        let operation = ImageLoadOperation(
            cache: cache,
            key: key,
            size: size,
            scale: scale,
            mode: contentMode,
            completion: completion
        )
        queue.addOperation(operation)
        return operation
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

class ImageLoadOperation: Operation, Cancellable {
    let cache: ImageCache
    let key: String
    var result: UIImage?
    var completion: ((UIImage?) -> Void)
    var size: CGSize
    var scale: CGFloat
    var mode: UIView.ContentMode
    
    init(cache: ImageCache,
         key: String,
         size: CGSize,
         scale: CGFloat,
         mode: UIView.ContentMode,
         completion: @escaping (UIImage?) -> Void) {
        self.cache = cache
        self.key = key
        self.size = size
        self.scale = scale
        self.mode = mode
        self.completion = completion
    }
    
    override func main() {
        super.main()
        guard !isCancelled else { return }
        guard var result = cache.loadImage(key) else { return }
        guard !isCancelled else { return }
        result = result.scale(to: size, scale: scale, mode: mode)
        self.result = result
        DispatchQueue.main.async { [completion] in completion(result) }
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
