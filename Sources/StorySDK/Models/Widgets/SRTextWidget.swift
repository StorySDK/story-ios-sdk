//
//  SRTextWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 02.02.2022.
//

import UIKit

public struct SRTextWidget: Decodable {
    public var text: String
    public var fontSize: Double
    public var fontFamily: String
    public var fontParams: SRFontParamsValue
    public var align: String
    public var color: SRColor?
    public var backgroundColor: SRColor?
    public var withFill: Bool
    public var opacity: Double
    public var widgetOpacity: Double
    public var backgroundOpacity: Double
}
