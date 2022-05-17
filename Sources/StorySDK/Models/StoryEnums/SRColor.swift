//
//  SRColor.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

import UIKit

public enum SRColor {
    case color(UIColor)
    case gradient([UIColor])
    case image(URL)
    
    init?(json: Json) {
        guard let type = json["type"] as? String else { return nil }
        switch type {
        case "color":
            guard let value = json["value"] as? String else { return nil }
            guard let color = UIColor.parse(rawValue: value) else { return nil }
            self = .color(color)
        case "gradient":
            guard let value = json["value"] as? [String] else { return nil }
            let colors = value.compactMap { UIColor.parse(rawValue: $0) }
            guard !colors.isEmpty else { return nil }
            self = .gradient(colors)
        case "image":
            guard let value = json["value"] as? String else { return nil }
            guard let url = URL(string: value) else { return nil }
            self = .image(url)
        default:
            return nil
        }
    }
}
