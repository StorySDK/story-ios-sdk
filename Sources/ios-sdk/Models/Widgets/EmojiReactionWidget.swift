//
//  EmojiReactionWidget.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct EmojiReactionWidget {
    let emoji: [EmojiValue]
    let color: String
    
    public init() {
        self.emoji = [EmojiValue]()
        self.color = "FFFFFF"
    }
    
    public init(from dict: Json) {
        var emoji = [EmojiValue]()
        if let array = dict["emoji"] as? NSArray {
            for emojiDict in array {
                let em = EmojiValue(from: emojiDict as! Json)
                emoji.append(em)
            }
        }
        self.emoji = emoji
        self.color = dict["color"] as? String ?? "FFFFFF"
    }
}
