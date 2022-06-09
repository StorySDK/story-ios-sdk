//
//  String+Extensions.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 08.02.2022.
//

import UIKit

extension String {
    func imageFromEmoji(fontSize: CGFloat = 34) -> UIImage? {
        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes = [NSAttributedString.Key.font: font]
        let string = NSAttributedString(string: self, attributes: attributes)
        let imageSize = string.size()
        let render = UIGraphicsImageRenderer(size: imageSize)
        return render.image { _ in
            string.draw(in: .init(origin: .zero, size: imageSize))
        }
    }
    
    func toHexEncodedString(uppercase: Bool = true, prefix: String = "", separator: String = "") -> String {
        return unicodeScalars.map { prefix + .init($0.value, radix: 16, uppercase: uppercase) } .joined(separator: separator)
    }
}
