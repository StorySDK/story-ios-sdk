//
//  UIImage+Extension.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 11.02.2022.
//

import UIKit

extension UIImage {
    /// Create image with color
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }

    convenience init?(bounds: CGRect, gradientLayer: CAGradientLayer) {
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    func tintedWithLinearGradientColors(colors: [UIColor]) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1, y: -1)

        context.setBlendMode(.normal)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        // Create gradient
        var colorsArr = [CGColor]()
        for color in colors {
            colorsArr.append(color.cgColor)
        }
        let colors = colorsArr as CFArray
        let space = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: space, colors: colors, locations: nil)

        // Apply gradient
        context.clip(to: rect, mask: self.cgImage!)
        context.drawLinearGradient(gradient!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: self.size.height), options: .drawsAfterEndLocation)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return gradientImage!
    }

    /**
      Resizes the image.

      - Parameters:
        - scale: If this is 1
        - newSize: is the size in pixels.
    */
      @nonobjc public func resized(to newSize: CGSize, scale: CGFloat = 1) -> UIImage {
          let format = UIGraphicsImageRendererFormat.default()
          format.scale = scale
          let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
          let image = renderer.image { _ in
              draw(in: CGRect(origin: .zero, size: newSize))
          }
          return image
      }

}
