//
//  UIColor+Extensions.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

extension StoryColor {
    static func parse(rawValue: String) -> StoryColor? {
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
    
    static func parseHex(_ string: String) -> StoryColor? {
        let array = Array(string)
        let parts: [CGFloat] = stride(from: 1, to: array.count - 1, by: 2)
            .compactMap { i -> CGFloat? in
                let part = "\(array[i])\(array[i + 1])"
                guard let value = UInt32(part, radix: 16) else { return nil }
                return CGFloat(value)
        }
        return parseParts(parts)
    }
    
    static func parseRgba(_ string: String) -> StoryColor? {
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
    
    static func parseRgb(_ string: String) -> StoryColor? {
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
    
    static func rgb(_ value: Int) -> StoryColor {
        let red: CGFloat = CGFloat((value & 0xff0000) >> 16)
        let green: CGFloat = CGFloat((value & 0x00ff00) >> 8)
        let blue: CGFloat = CGFloat(value & 0x0000ff)

        return StoryColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1.0)
    }
    
    static func parseParts(_ parts: [CGFloat]) -> StoryColor? {
        guard parts.count >= 3 else { return nil }
        return .init(
            red: parts[0] / 0xff,
            green: parts[1] / 0xff,
            blue: parts[2] / 0xff,
            alpha: parts.count > 3 ? parts[3] / 0xff : 1
        )
    }
}
