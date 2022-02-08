//
//  ClickMeWidget.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct ClickMeWidget {
    let fontFamily: String
    let fontSize: Double
    let fontParams: FontParamsValue
    let iconSize: Double
    let opacity: Double
    let color: BorderType
    let text: String
    let icon: IconValue
    let url: String
    let borderRadius: Double
    let backgroundColor: BackgroundType
    let hasBorder: Bool
    let hasIcon: Bool
    let borderWidth: Double
    let borderColor: BackgroundType
    let borderOpacity: Double
    
    public init() {
        self.fontFamily = "Roboto"
        self.fontSize = 15
        self.fontParams = FontParamsValue()
        self.iconSize = 24
        self.opacity = 100
        self.color = BorderType.null("null")
        self.text = ""
        self.icon = IconValue()
        self.url = ""
        self.borderRadius = 0
        self.backgroundColor = BackgroundType.null("null")
        self.hasBorder = false
        self.hasIcon = false
        self.borderWidth = 0
        self.borderColor = BackgroundType.null("null")
        self.borderOpacity = 0
    }
    
    public init(from dict: Json) {
        self.fontFamily = dict["fontFamily"] as? String ?? "Roboto"
        self.fontSize = dict["fontSize"] as? Double ?? 15
        if let fontDict = dict["fontParams"] as? Json {
            self.fontParams = FontParamsValue(from: fontDict)
        }
        else {
            self.fontParams = FontParamsValue()
        }
        self.iconSize = dict["iconSize"] as? Double ?? 24
        self.opacity = dict["opacity"] as? Double ?? 100
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
        self.text = dict["text"] as? String ?? ""
        if let iconDict = dict["icon"] as? Json {
            self.icon = IconValue(from: iconDict)
        }
        else {
            self.icon = IconValue()
        }
        self.url = dict["url"] as? String ?? ""
        self.borderRadius = dict["borderRadius"] as? Double ?? 0
        if let backgroundDict = dict["backgroundColor"] as? Json {
            let type = backgroundDict["type"] as! String
            if type == "color" || type == "image" {
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
        self.hasBorder = dict["hasBorder"] as? Bool ?? false
        self.hasIcon = dict["hasIcon"] as? Bool ?? false
        self.borderWidth = dict["borderWidth"] as? Double ?? 0
        if let borderDict = dict["borderColor"] as? Json {
            let type = borderDict["type"] as! String
            if type == "color" {
                self.borderColor = BackgroundType.color(ColorValue(from: borderDict))
            }
            else if type == "gradient" {
                self.borderColor = BackgroundType.gradient(GradientValue(from: borderDict))
            }
            else {
                self.borderColor = BackgroundType.null("null")
            }
        }
        else {
            self.borderColor = BackgroundType.null("null")
        }
        self.borderOpacity = dict["borderOpacity"] as? Double ?? 0
    }
}
