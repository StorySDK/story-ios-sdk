//
//  RectangleWidget.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct RectangleWidget {
    let fillColor: BackgroundType
    let fillBorderRadius: Double
    let fillOpacity: Double
    let widgetOpacity: Double
    let strokeThickness: Double
    let strokeColor: BorderType
    let strokeOpacity: Double
    let hasBorder: Bool
    
    public init() {
        self.fillColor = BackgroundType.null("null")
        self.fillBorderRadius = 0
        self.fillOpacity = 100
        self.widgetOpacity = 0
        self.strokeThickness = 0
        self.strokeColor = BorderType.null("null")
        self.strokeOpacity = 0
        self.hasBorder = false
    }
    
    public init(from dict: Json) {
        if let filldDict = dict["fillColor"] as? Json {
            let type = filldDict["type"] as! String
            if type == "color" || type == "image" || type == "video"{
                self.fillColor = BackgroundType.color(ColorValue(from: filldDict))
            }
            else if type == "gradient" {
                self.fillColor = BackgroundType.gradient(GradientValue(from: filldDict))
            }
            else {
                self.fillColor = BackgroundType.null("null")
            }
        }
        else {
            self.fillColor = BackgroundType.null("null")
        }
        self.fillBorderRadius = dict["fillBorderRadius"] as? Double ?? 0
        self.fillOpacity = dict["fillOpacity"] as? Double ?? 100
        self.widgetOpacity = dict["widgetOpacity"] as? Double ?? 100
        self.strokeThickness = dict["strokeThickness"] as? Double ?? 0
        if let strokeDict = dict["strokeColor"] as? Json {
            let type = strokeDict["type"] as! String
            if type == "color" {
                self.strokeColor = BorderType.color(ColorValue(from: strokeDict))
            }
            else if type == "gradient" {
                self.strokeColor = BorderType.gradient(GradientValue(from: strokeDict))
            }
            else {
                self.strokeColor = BorderType.null("null")
            }
        }
        else {
            self.strokeColor = BorderType.null("null")
        }
        self.strokeOpacity = dict["strokeOpacity"] as? Double ?? 0
        self.hasBorder = dict["hasBorder"] as? Bool ?? false
    }
}
