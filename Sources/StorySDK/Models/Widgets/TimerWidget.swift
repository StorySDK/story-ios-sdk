//
//  TimerWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct TimerWidget: Decodable {
    let time: Int
    let text: String
    let color: String
    
    enum CodingKeys: String, CodingKey {
        case time, text, color
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.time = try container.decode(Int.self, forKey: .time)
        self.text = try container.decode(String.self, forKey: .text)
        self.color = try container.decode(String.self, forKey: .color)
    }
    
    public init() {
        self.time = 0
        self.text = ""
        self.color = "#FFFFFF"
    }
    
    public init(from dict: Json) {
        self.time = dict["time"] as? Int ?? 0
        self.text = dict["text"] as? String ?? ""
        self.color = dict["color"] as? String ?? "#FFFFFF"
    }
}
