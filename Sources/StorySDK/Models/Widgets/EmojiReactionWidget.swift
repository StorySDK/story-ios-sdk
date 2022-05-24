//
//  EmojiReactionWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct EmojiReactionWidget: Decodable {
    let emoji: [EmojiValue]
    let color: SRThemeColor
}
