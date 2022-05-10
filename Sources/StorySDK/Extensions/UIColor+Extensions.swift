//
//  UIColor+Extensions.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

#if os(iOS)
import UIKit

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    convenience init(rgbString: String) {
        let splitted = rgbString.split(separator: "(")
        if splitted.count > 1 {
            let colorString = String(splitted[1]).replacingOccurrences(of: ")", with: "")
            let rgbParts = colorString.split(separator: ",")
            var r: CGFloat = 255
            var g: CGFloat = 255
            var b: CGFloat = 255
            var a: CGFloat = 1
            for i in 0 ..< rgbParts.count {
                let value = String(rgbParts[i]).replacingOccurrences(of: " ", with: "")
                if let n = NumberFormatter().number(from: value) {
                    let f = CGFloat(truncating: n)
                    if i == 0 {
                        r = f
                    } else if i == 1 {
                        g = f
                    } else if i == 2 {
                        b = f
                    } else {
                        a = f
                    }
                }
            }
            self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a))
        } else {
            self.init()
        }
    }
}
#endif
