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
    
    public init() {
        self.text = ""
        self.fontSize = 15
        self.fontFamily = "Roboto"
        self.fontParams = FontParamsValue()
        self.align = "center"
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
        } else {
            self.fontParams = FontParamsValue()
        }
        self.align = dict["align"] as? String ?? ""
        self.withFill = dict["withFill"] as? Bool ?? false
        self.opacity = dict["opacity"] as? Double ?? 100
        self.widgetOpacity = dict["widgetOpacity"] as? Double ?? 100
        self.backgroundOpacity = dict["backgroundOpacity"] as? Double ?? 100
        (dict["color"] as? Json).map { color = .init(json: $0) }
        (dict["backgroundColor"] as? Json).map { backgroundColor = .init(json: $0) }
    }
}
