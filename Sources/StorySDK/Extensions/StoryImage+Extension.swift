//
//  StoryImage+Extension.swift
//  StorySDK
//
//  Created by Ingvarr Alef on 11.07.2023.
//

#if os(macOS)
    import Cocoa

    extension StoryImage {
        public func scale(to size: CGSize, scale: CGFloat = 1, mode: StoryContentMode = StoryViewContentMode.scaleAspectFill) -> StoryImage {
            return StoryImage()
        }
    }
#elseif os(iOS)
    import UIKit
    import AVFoundation

    extension StoryImage {
        public func scale(to size: CGSize, scale: CGFloat = 1, mode: StoryContentMode = StoryViewContentMode.scaleAspectFill) -> StoryImage {
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
#endif
