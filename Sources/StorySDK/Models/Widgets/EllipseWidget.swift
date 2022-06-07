//
//  EllipseWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct EllipseWidget: Decodable {
    var fillColor: SRColor?
    var fillOpacity: Double
    var strokeThickness: Double
    var strokeColor: SRColor?
    var widgetOpacity: Double
    var strokeOpacity: Double
    var hasBorder: Bool
}
