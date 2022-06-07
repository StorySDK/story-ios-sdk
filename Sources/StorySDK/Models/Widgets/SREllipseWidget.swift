//
//  SREllipseWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct SREllipseWidget: Decodable {
    public var fillColor: SRColor?
    public var fillOpacity: Double
    public var strokeThickness: Double
    public var strokeColor: SRColor?
    public var widgetOpacity: Double
    public var strokeOpacity: Double
    public var hasBorder: Bool
}
