//
//  SRLinkWidget.swift
//  StorySDK
//
//  Created by Ingvarr Alef on 18/08/2024.
//

import Foundation

public struct SRLinkWidget: Decodable {
    public var fontFamily: String
    public var fontSize: Double
    public var fontParams: SRFontParamsValue
    public var opacity: Double
    public var color: SRColor?
    public var text: String
    public var url: String
    public var backgroundColor: SRColor?
}

