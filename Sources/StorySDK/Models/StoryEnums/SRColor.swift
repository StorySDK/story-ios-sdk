//
//  SRColor.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

import UIKit

public enum SRColor: Decodable {
    case color(UIColor)
    case gradient([UIColor])
    case image(URL)
//    
//    init?(json: Json) {
//        guard let type = json["type"] as? String else { return nil }
//        switch type {
//        case "color":
//            guard let value = json["value"] as? String else { return nil }
//            guard let color = UIColor.parse(rawValue: value) else { return nil }
//            self = .color(color)
//        case "gradient":
//            guard let value = json["value"] as? [String] else { return nil }
//            let colors = value.compactMap { UIColor.parse(rawValue: $0) }
//            guard !colors.isEmpty else { return nil }
//            self = .gradient(colors)
//        case "image":
//            guard let value = json["value"] as? String else { return nil }
//            guard let url = URL(string: value) else { return nil }
//            // fileId ?
//            self = .image(url)
//        default:
//            return nil
//        }
//    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "color":
            let rawColor = try container.decode(String.self, forKey: .value)
            guard let color = UIColor.parse(rawValue: rawColor) else {
                throw SRError.unknownColor(rawColor)
            }
            self = .color(color)
        case "gradient":
            let rawColors = try container.decode([String].self, forKey: .value)
            var colors: [UIColor] = []
            for rawColor in rawColors {
                guard let color = UIColor.parse(rawValue: rawColor) else {
                    throw SRError.unknownColor(rawColor)
                }
                colors.append(color)
            }
            self = .gradient(colors)
        case "image":
            let url = try container.decode(URL.self, forKey: .value)
            self = .image(url)
        default:
            throw SRError.unknownType
        }
    }
}

extension SRColor {
    enum CodingKeys: String, CodingKey {
        case type, value
    }
}
