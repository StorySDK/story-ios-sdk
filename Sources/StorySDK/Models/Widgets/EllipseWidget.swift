//
//  EllipseWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct EllipseWidget {
    var fillColor: SRColor?
    var fillOpacity: Double
    var strokeThickness: Double
    var strokeColor: SRColor?
    var widgetOpacity: Double
    var strokeOpacity: Double
    var hasBorder: Bool
    
    public init() {
        self.fillOpacity = 100
        self.widgetOpacity = 0
        self.strokeThickness = 0
        self.strokeOpacity = 0
        self.hasBorder = false
    }
    
    public init(from dict: Json) {
        fillOpacity = dict["fillOpacity"] as? Double ?? 100
        widgetOpacity = dict["widgetOpacity"] as? Double ?? 100
        strokeThickness = dict["strokeThickness"] as? Double ?? 0
        strokeOpacity = dict["strokeOpacity"] as? Double ?? 0
        hasBorder = dict["hasBorder"] as? Bool ?? false
        (dict["fillColor"] as? Json).map { fillColor = .init(json: $0) }
        (dict["strokeColor"] as? Json).map { strokeColor = .init(json: $0) }
    }
}
