//
//  GiphyWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct GiphyWidget: Decodable {
    let gif: String
    let widgetOpacity: Double
    let borderRadius: Double
    
    enum CodingKeys: String, CodingKey {
        case gif, widgetOpacity, borderRadius
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.gif = try container.decode(String.self, forKey: .gif)
        self.widgetOpacity = try container.decode(Double.self, forKey: .widgetOpacity)
        self.borderRadius = try container.decode(Double.self, forKey: .borderRadius)
    }
    
    public init() {
        self.gif = ""
        self.widgetOpacity = 100
        self.borderRadius = 0
    }
    
    public init(from dict: Json) {
        self.gif = dict["gif"] as? String ?? ""
        self.widgetOpacity = dict["widgetOpacity"] as? Double ?? 100
        self.borderRadius = dict["borderRadius"] as? Double ?? 0
    }
}
