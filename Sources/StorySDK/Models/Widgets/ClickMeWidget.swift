//
//  ClickMeWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct ClickMeWidget: Decodable {
    var fontFamily: String
    var fontSize: Double
    var fontParams: FontParamsValue
    var iconSize: Double
    var opacity: Double
    var color: SRColor?
    var text: String
    var icon: SRIcon
    var url: String
    var borderRadius: Double
    var backgroundColor: SRColor?
    var hasBorder: Bool
    var hasIcon: Bool
    var borderWidth: Double
    var borderColor: SRColor?
    var borderOpacity: Double
}
