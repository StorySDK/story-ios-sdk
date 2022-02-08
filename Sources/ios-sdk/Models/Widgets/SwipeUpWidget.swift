//
//  SwipeUpWidget.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct SwipeUpWidget {
    let text: String
    let opacity: Double
    let iconSize: Double
    let fontSize: Double
    let fontFamily: String
    let fontParams: FontParamsValue
    let color: BorderType
    let url: String
    let icon: IconValue
    
    public init() {
        self.text = ""
        self.opacity = 100
        self.iconSize = 24
        self.fontSize = 15
        self.fontFamily = "Roboto"
        self.fontParams = FontParamsValue()
        self.color = BorderType.null("null")
        self.url = ""
        self.icon = IconValue()
    }
    
    public init(from dict: Json) {
        self.text = dict["text"] as? String ?? ""
        self.opacity = dict["opacity"] as? Double ?? 100
        self.iconSize = dict["iconSize"] as? Double ?? 24
        self.fontFamily = dict["fontFamily"] as? String ?? "Roboto"
        self.fontSize = dict["fontSize"] as? Double ?? 15
        if let fontDict = dict["fontParams"] as? Json {
            self.fontParams = FontParamsValue(from: fontDict)
        }
        else {
            self.fontParams = FontParamsValue()
        }
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
        self.url = dict["url"] as? String ?? ""
        if let iconDict = dict["icon"] as? Json {
            self.icon = IconValue(from: iconDict)
        }
        else {
            self.icon = IconValue()
        }
    }
}
