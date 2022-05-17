//
//  ClickMeWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct ClickMeWidget {
    var fontFamily: String
    var fontSize: Double
    var fontParams: FontParamsValue
    var iconSize: Double
    var opacity: Double
    var color: SRColor?
    var text: String
    var icon: IconValue
    var url: String
    var borderRadius: Double
    var backgroundColor: SRColor?
    var hasBorder: Bool
    var hasIcon: Bool
    var borderWidth: Double
    var borderColor: SRColor?
    var borderOpacity: Double
    
    public init() {
        self.fontFamily = "Roboto"
        self.fontSize = 15
        self.fontParams = FontParamsValue()
        self.iconSize = 24
        self.opacity = 100
        self.text = ""
        self.icon = IconValue()
        self.url = ""
        self.borderRadius = 0
        self.hasBorder = false
        self.hasIcon = false
        self.borderWidth = 0
        self.borderOpacity = 0
    }
    
    public init(from dict: Json) {
        self.fontFamily = dict["fontFamily"] as? String ?? "Roboto"
        self.fontSize = dict["fontSize"] as? Double ?? 15
        if let fontDict = dict["fontParams"] as? Json {
            self.fontParams = FontParamsValue(from: fontDict)
        } else {
            self.fontParams = FontParamsValue()
        }
        self.iconSize = dict["iconSize"] as? Double ?? 24
        self.opacity = dict["opacity"] as? Double ?? 100
        self.text = dict["text"] as? String ?? ""
        if let iconDict = dict["icon"] as? Json {
            self.icon = IconValue(from: iconDict)
        } else {
            self.icon = IconValue()
        }
        self.url = dict["url"] as? String ?? ""
        self.borderRadius = dict["borderRadius"] as? Double ?? 0
        self.hasBorder = dict["hasBorder"] as? Bool ?? false
        self.hasIcon = dict["hasIcon"] as? Bool ?? false
        self.borderWidth = dict["borderWidth"] as? Double ?? 0
        self.borderOpacity = dict["borderOpacity"] as? Double ?? 0
        (dict["borderColor"] as? Json).map { borderColor = .init(json: $0) }
        (dict["backgroundColor"] as? Json).map { backgroundColor = .init(json: $0) }
        (dict["color"] as? Json).map { color = .init(json: $0) }
    }
}
