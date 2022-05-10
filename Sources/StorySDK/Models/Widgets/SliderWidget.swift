//
//  SliderWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct SliderWidget {
    let text: String?
    let color: String
    let emoji: EmojiValue
    let value: Double
    
    public init() {
        self.text = ""
        self.color = ""
        self.emoji = EmojiValue()
        self.value = 0
    }
    
    public init(from dict: Json) {
        self.text = dict["text"] as? String ?? ""
        self.color = dict["color"] as? String ?? ""
        if let emojiDict = dict["emoji"] as? Json {
            self.emoji = EmojiValue(from: emojiDict)
        } else {
            self.emoji = EmojiValue()
        }
        self.value = dict["value"] as? Double ?? 0
    }
}
