//
//  TextWidget.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 02.02.2022.
//

import UIKit

public struct TextWidget {
    let text: String
    let fontSize: Double
    let fontFamily: String
    let fontParams: FontParamsValue
    let align: String
    let color: BorderType
    let backgroundColor: BackgroundType
    let withFill: Bool
    let opacity: Double
    let widgetOpacity: Double
    let backgroundOpacity: Double
    
    public init() {
        self.text = ""
        self.fontSize = 15
        self.fontFamily = "Roboto"
        self.fontParams = FontParamsValue()
        self.align = "center"
        self.color = BorderType.null("null")
        self.backgroundColor = BackgroundType.null("null")
        self.withFill = false
        self.opacity = 100
        self.widgetOpacity = 100
        self.backgroundOpacity = 100
    }
    
    public init(from dict: Json) {
        self.text = dict["text"] as? String ?? ""
        self.fontFamily = dict["fontFamily"] as? String ?? "Roboto"
        self.fontSize = dict["fontSize"] as? Double ?? 15
        if let fontDict = dict["fontParams"] as? Json {
            self.fontParams = FontParamsValue(from: fontDict)
        }
        else {
            self.fontParams = FontParamsValue()
        }
        self.align = dict["align"] as? String ?? ""
        if let colorDict = dict["color"] as? Json {
            let type = colorDict["type"] as! String
            if type == "color" {
                self.color = BorderType.color(ColorValue(from: colorDict))
            }
            else if type == "gradient" {
                self.color = BorderType.gradient(GradientValue(from: colorDict))
            }
            else {
                self.color = BorderType.null("null")
            }
        }
        else {
            self.color = BorderType.null("null")
        }
        if let backgroundDict = dict["backgroundColor"] as? Json {
            let type = backgroundDict["type"] as! String
            if type == "color" || type == "image" || type == "video"{
                self.backgroundColor = BackgroundType.color(ColorValue(from: backgroundDict))
            }
            else if type == "gradient" {
                self.backgroundColor = BackgroundType.gradient(GradientValue(from: backgroundDict))
            }
            else {
                self.backgroundColor = BackgroundType.null("null")
            }
        }
        else {
            self.backgroundColor = BackgroundType.null("null")
        }
        self.withFill = dict["withFill"] as? Bool ?? false
        self.opacity = dict["opacity"] as? Double ?? 100
        self.widgetOpacity = dict["widgetOpacity"] as? Double ?? 100
        self.backgroundOpacity = dict["backgroundOpacity"] as? Double ?? 100
    }
}
