//
//  SRClickMeWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct SRClickMeWidget: Decodable {
    public var fontFamily: String
    public var fontSize: Double
    public var fontParams: SRFontParamsValue
    public var iconSize: Double
    public var opacity: Double
    public var color: SRColor?
    public var text: String
    public var icon: SRIcon
    public var url: String
    public var borderRadius: Double
    public var backgroundColor: SRColor?
    public var hasBorder: Bool
    public var hasIcon: Bool
    public var borderWidth: Double
    public var borderColor: SRColor?
    public var borderOpacity: Double
}
