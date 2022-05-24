//
//  SwipeUpWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct SwipeUpWidget: Decodable {
    let text: String
    let opacity: Double
    let iconSize: Double
    let fontSize: Double
    let fontFamily: String
    let fontParams: FontParamsValue
    let color: SRColor
    let url: String
    let icon: SRIcon
}
