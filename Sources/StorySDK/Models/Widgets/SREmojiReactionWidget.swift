//
//  SREmojiReactionWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct SREmojiReactionWidget: Decodable {
    public var emoji: [SREmojiValue]
    public var color: SRThemeColor
}
