//
//  SRThemeColor.swift
//  
//
//  Created by Aleksei Cherepanov on 23.05.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public enum SRThemeColor: Decodable {
    case purple, blue, darkBlue, white, green, orange, orangeRed, yellow
    case black, red, grey, custom(String)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value {
        case "purple": self = .purple
        case "blue": self = .blue
        case "darkBlue": self = .darkBlue
        case "white": self = .white
        case "green": self = .green
        case "orange": self = .orange
        case "orangeRed": self = .orangeRed
        case "yellow": self = .yellow
        case "black": self = .black
        case "red": self = .red
        case "grey": self = .grey
        default: self = .custom(value)
        }
    }
    
    public var color: StoryColor {
        switch self {
        case .purple:
            return StoryColor.rgb(0xae13ab)
        case .blue:
            return StoryColor.rgb(0x00b2ff)
        case .darkBlue:
            return StoryColor.rgb(0x366efe)
        case .white:
            return StoryColor.rgb(0xffffff)
        case .green:
            return StoryColor.rgb(0x44d937)
        case .orange:
            return StoryColor.rgb(0xffa93d)
        case .orangeRed:
            return StoryColor.rgb(0xff4c25)
        case .yellow:
            return StoryColor.rgb(0xf3cc00)
        case .black:
            return StoryColor.rgb(0x05051d)
        case .red:
            return StoryColor.rgb(0xd62727)
        case .grey:
            return StoryColor.rgb(0xdddbde)
        case .custom:
            return .white
        }
    }
    
    public var cgColor: CGColor { color.cgColor }
    
    public var gradient: [StoryColor] {
        switch self {
        case .purple:
            let from = StoryColor.rgb(0xce25ca)
            let to = StoryColor.rgba(0xea0e4ef8)
            
            return [from, to]
        default:
            let color = self.color
            return [color, color]
        }
    }
}
