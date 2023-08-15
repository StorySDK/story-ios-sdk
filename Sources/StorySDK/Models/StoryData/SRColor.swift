//
//  SRColor.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public enum SRColor: Decodable {
    case color(StoryColor, Bool)
    case gradient([StoryColor], Bool)
    case image(URL, Bool)
    case video(URL, Bool)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let filled = try? container.decode(Bool.self, forKey: .isFilled)
        
        let isFilled = filled ?? false
        
        switch type {
        case "color":
            let rawColor = try container.decode(String.self, forKey: .value)
            guard let color = StoryColor.parse(rawValue: rawColor) else {
                throw SRError.unknownColor(rawColor)
            }
            self = .color(color, isFilled)
        case "gradient":
            let rawColors = try container.decode([String].self, forKey: .value)
            var colors: [StoryColor] = []
            for rawColor in rawColors {
                guard let color = StoryColor.parse(rawValue: rawColor) else {
                    throw SRError.unknownColor(rawColor)
                }
                colors.append(color)
            }
            self = .gradient(colors, isFilled)
        case "image":
            let url = try container.decode(URL.self, forKey: .value)
            self = .image(url, isFilled)
        case "video":
            let url = try container.decode(URL.self, forKey: .value)
            self = .video(url, isFilled)
        default:
            throw SRError.unknownType
        }
    }
}

extension SRColor {
    enum CodingKeys: String, CodingKey {
        case type, value, isFilled
    }
}
