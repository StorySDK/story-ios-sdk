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

extension UIColor {
    static func parse(rawValue: String) -> UIColor? {
        if rawValue.hasPrefix("#") {
            return .parseHex(rawValue)
        } else if rawValue.hasPrefix("rgba") {
            return .parseRgba(rawValue)
        } else if rawValue.hasPrefix("rgb") {
            return .parseRgb(rawValue)
        } else {
            return nil
        }
    }
    
    static func parseHex(_ string: String) -> UIColor? {
        let array = Array(string)
        let parts: [CGFloat] = stride(from: 1, to: array.count - 1, by: 2)
            .compactMap { i -> CGFloat? in
                let part = "\(array[i])\(array[i + 1])"
                guard let value = UInt32(part, radix: 16) else { return nil }
                return CGFloat(value)
        }
        return parseParts(parts)
    }
    
    static func parseRgba(_ string: String) -> UIColor? {
        var string = string
        string = "\(string.dropFirst(5).dropLast(1))"
        let parts: [CGFloat] = string.split(separator: ",")
            .compactMap { part in
                guard let value = UInt32(part, radix: 10) else { return nil }
                return CGFloat(value)
            }
        return parseParts(parts)
    }
    
    static func parseRgb(_ string: String) -> UIColor? {
        var string = string
        string = "\(string.dropFirst(4).dropLast(1))"
        let parts: [CGFloat] = string.split(separator: ",")
            .compactMap { part in
                guard let value = UInt32(part, radix: 10) else { return nil }
                return CGFloat(value)
            }
        return parseParts(parts)
    }
    
    static func parseParts(_ parts: [CGFloat]) -> UIColor? {
        guard parts.count >= 3 else { return nil }
        return .init(
            red: parts[0] / 0xff,
            green: parts[2] / 0xff,
            blue: parts[2] / 0xff,
            alpha: parts.count > 3 ? parts[3] / 0xff : 1
        )
    }
}

#endif
