//
//  RectangleWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct RectangleWidget: Decodable {
    var fillColor: SRColor?
    var fillBorderRadius: Double
    var fillOpacity: Double
    var widgetOpacity: Double
    var strokeThickness: Double
    var strokeColor: SRColor?
    var strokeOpacity: Double
    var hasBorder: Bool
}
