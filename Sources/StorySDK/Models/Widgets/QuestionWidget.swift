//
//  QuestionWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct QuestionWidget: Decodable {
    let question: String
    let confirm: String
    let decline: String
    let color: String
    
    enum CodingKeys: String, CodingKey {
        case question, confirm, decline, color
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.question = try container.decode(String.self, forKey: .question)
        self.confirm = try container.decode(String.self, forKey: .confirm)
        self.decline = try container.decode(String.self, forKey: .decline)
        self.color = try container.decode(String.self, forKey: .color)
    }
    
    public init() {
        self.question = ""
        self.confirm = ""
        self.decline = ""
        self.color = ""
    }
    
    public init(from dict: Json) {
        self.question = dict["question"] as? String ?? ""
        self.confirm = dict["confirm"] as? String ?? ""
        self.decline = dict["decline"] as? String ?? ""
        self.color = dict["color"] as? String ?? ""
    }
}
