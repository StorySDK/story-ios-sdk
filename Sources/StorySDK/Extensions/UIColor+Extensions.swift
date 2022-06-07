//
//  UIColor+Extensions.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

#if os(iOS)
import UIKit

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
        var parts: [CGFloat] = string.split(separator: ",")
            .map { String($0.filter { !$0.isWhitespace }) }
            .compactMap { part in
                guard let value = UInt32(part, radix: 10) else { return nil }
                return CGFloat(value)
            }
        guard parts.count == 4 else { return nil }
        parts[3] *= 255
        return parseParts(parts)
    }
    
    static func parseRgb(_ string: String) -> UIColor? {
        var string = string
        string = "\(string.dropFirst(4).dropLast(1))"
        let parts: [CGFloat] = string.split(separator: ",")
            .map { String($0.filter { !$0.isWhitespace }) }
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
            green: parts[1] / 0xff,
            blue: parts[2] / 0xff,
            alpha: parts.count > 3 ? parts[3] / 0xff : 1
        )
    }
    
    
    // MARK: - TODO: Remove it
    
    static let sliderTint = #colorLiteral(red: 0.3921568627, green: 0.3921568627, blue: 0.3921568627, alpha: 0.250212585)  // #646464 with alpha = 0.25
    static let sliderStart = #colorLiteral(red: 0.8078431373, green: 0.1450980392, blue: 0.7921568627, alpha: 1)  // #CE25CA
    static let sliderFinish = #colorLiteral(red: 0.9176470588, green: 0.05490196078, blue: 0.3058823529, alpha: 1)  // #EA0E4E
    static let orangeRed = #colorLiteral(red: 1, green: 0.2980392157, blue: 0.1450980392, alpha: 1)  // #FF4C25
    static let white = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)  // #FFFFFF
    static let black = #colorLiteral(red: 0.01960784314, green: 0.01960784314, blue: 0.1137254902, alpha: 1)  // #05051D
}

#endif
