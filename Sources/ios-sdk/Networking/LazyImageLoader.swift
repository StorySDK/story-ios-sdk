//
//  LazyImageLoader.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 09.02.2022.
//

import Foundation
import UIKit

/// LazyImage error object
///
/// - CallFailed: The download request did not succeed.
/// - noDataAvailable: The download request returned nil response.
/// - CorruptedData: The downloaded data are corrupted and can not be read.
enum LazyImageLoaderError: Error {
    case CallFailed
    case noDataAvailable
    case CorruptedData
}

extension LazyImageLoaderError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .CallFailed:
            return NSLocalizedString("The download request did not succeed.", comment: "Error")
            
        case .noDataAvailable:
            return NSLocalizedString("The download request returned nil response.", comment: "Error")
            
        case .CorruptedData:
            return NSLocalizedString("The downloaded data are corrupted and can not be read.", comment: "Error")
        }
    }
}

final class LazyImageLoader {
    static let shared = LazyImageLoader()

    /// The URL session request
    private var session: URLSession?

    /// Method for loading the image for a specific URL.
    ///
    /// - Parameters:
    ///   - url: The corresponding URL of the image
    ///   - completion: Closure with the image or error if any
    func loadImage(url: URL?, completion: @escaping (_ image: UIImage?, _ error: LazyImageLoaderError?) -> Void) -> Void {
        
        guard let url = url else {
            //Call did not succeed
            let error: LazyImageLoaderError = LazyImageLoaderError.CallFailed
            completion(nil, error)
            return
        }
        
        //Lazy load image (Asychronous call)
        let urlRequest: URLRequest = URLRequest(url: url)
        
        let backgroundQueue = DispatchQueue(label: "imageBackgroundQue",
                                            qos: .background,
                                            target: nil)
        
        backgroundQueue.async(execute: {
            
            self.session = URLSession(configuration: URLSessionConfiguration.default)
            let task = self.session?.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                
                if response != nil {
                    let httpResponse:HTTPURLResponse = response as! HTTPURLResponse
                    
                    if httpResponse.statusCode != 200 {
                        Swift.debugPrint("LazyImage status code : \(httpResponse.statusCode)")
                        
                        //Completion block
                        //Call did not succeed
                        let error: LazyImageLoaderError = LazyImageLoaderError.CallFailed
                        completion(nil, error)
                        return
                    }
                }
                
                if data == nil {
                    if error != nil {
                        Swift.debugPrint("Error : \(error!.localizedDescription)")
                    }
                    Swift.debugPrint("LazyImage: No image data available")
                    
                    //No data available
                    let error: LazyImageLoaderError = LazyImageLoaderError.noDataAvailable
                    completion(nil, error)
                    return
                }
                
                completion(UIImage(data:data!), nil)
                return
            })
            task?.resume()
        })
    }

    internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1

        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        if CFDictionaryGetValueIfPresent(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque(), gifPropertiesPointer) == false {
            return delay
        }

        let gifProperties:CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)

        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }

        delay = delayObject as? Double ?? 0

        if delay < 0.1 {
            delay = 0.1 // Make sure they're not too fast
        }

        return delay
    }

    /// Method for loading the image for a specific URL.
    ///
    /// - Parameters:
    ///   - url: The corresponding URL of the gif image
    ///   - completion: Closure with the gif images or error if any
    func loadGifImage(url: URL?, size: CGSize, completion: @escaping (_ images: [UIImage]?, _ duration: TimeInterval, _ error: LazyImageLoaderError?) -> Void) -> Void {
        
        guard let url = url else {
            //Call did not succeed
            let error: LazyImageLoaderError = LazyImageLoaderError.CallFailed
            completion(nil, 0, error)
            return
        }
        
        //Lazy load image (Asychronous call)
        let urlRequest: URLRequest = URLRequest(url: url)
        
        let backgroundQueue = DispatchQueue(label: "gifImageBackgroundQue",
                                            qos: .background,
                                            target: nil)
        
        backgroundQueue.async(execute: {
            
            self.session = URLSession(configuration: URLSessionConfiguration.default)
            let task = self.session?.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                
                if response != nil {
                    let httpResponse:HTTPURLResponse = response as! HTTPURLResponse
                    
                    if httpResponse.statusCode != 200 {
                        Swift.debugPrint("LazyImage status code : \(httpResponse.statusCode)")
                        
                        //Completion block
                        //Call did not succeed
                        let error: LazyImageLoaderError = LazyImageLoaderError.CallFailed
                        completion(nil, 0, error)
                        return
                    }
                }
                
                if data == nil {
                    if error != nil {
                        Swift.debugPrint("Error : \(error!.localizedDescription)")
                    }
                    Swift.debugPrint("LazyImage: No image data available")
                    
                    //No data available
                    let error: LazyImageLoaderError = LazyImageLoaderError.noDataAvailable
                    completion(nil, 0, error)
                    return
                }
                
                guard let source =  CGImageSourceCreateWithData(data! as CFData, nil) else {
                    completion(nil, 0, LazyImageLoaderError.CorruptedData)
                        return
                    }
                var images = [UIImage]()
                let imageCount = CGImageSourceGetCount(source)
                let maxDimensionsInPixels = max(size.width, size.height) * UIScreen.main.scale
                let downOptions = [
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceShouldCacheImmediately: true,
                    kCGImageSourceCreateThumbnailWithTransform: true,
                    kCGImageSourceThumbnailMaxPixelSize: maxDimensionsInPixels
                ] as CFDictionary
                
                var totalDuration: TimeInterval = 0
                
                for i in 0 ..< imageCount {
                    if let image = CGImageSourceCreateImageAtIndex(source, i, downOptions) {
                        images.append(UIImage(cgImage: image))
                    }
                    let delay = LazyImageLoader.delayForImageAtIndex(i, source: source)
                    totalDuration += delay
                }
                completion(images, totalDuration, nil)
                return
            })
            task?.resume()
        })
    }

    //MARK: - Cancel session
    
    /// Cancels the image request.
    ///
    /// - Returns: true if there is a valid session
    public func cancel() -> Bool {
        
        guard let _ = self.session else {
            return false
        }

        self.session?.invalidateAndCancel()
        self.session = nil
        return true
    }

}
