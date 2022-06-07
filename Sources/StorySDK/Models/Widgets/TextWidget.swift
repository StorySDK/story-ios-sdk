//
//  TextWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 02.02.2022.
//

import UIKit

public struct TextWidget: Decodable {
    var text: String
    var fontSize: Double
    var fontFamily: String
    var fontParams: FontParamsValue
    var align: String
    var color: SRColor?
    var backgroundColor: SRColor?
    var withFill: Bool
    var opacity: Double
    var widgetOpacity: Double
    var backgroundOpacity: Double
}
