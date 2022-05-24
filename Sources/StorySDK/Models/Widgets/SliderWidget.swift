//
//  SliderWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct SliderWidget: Decodable {
    let text: String?
    let color: SRThemeColor
    let emoji: EmojiValue
    let value: Double
}
