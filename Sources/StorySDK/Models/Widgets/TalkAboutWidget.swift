//
//  TalkAboutWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct TalkAboutWidget: Decodable {
    let text: String
    let image: String?
    let color: String

    enum CodingKeys: String, CodingKey {
        case text, image, color
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.text = try container.decode(String.self, forKey: .text)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.color = try container.decode(String.self, forKey: .color)
    }
    
    public init() {
        self.text = ""
        self.image = nil
        self.color = ""
    }
    
    public init(from dict: Json) {
        self.text = dict["text"] as? String ?? ""
        self.image = dict["image"] as? String
        self.color = dict["color"] as? String ?? ""
    }
}
