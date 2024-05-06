//
//  SRAnswersFont.swift
//  StorySDK
//
//  Created by Igor Efremov on 09.05.2023.
//

import Foundation

public struct SRAnswersFont: Decodable {
    public var fontFamily: String
    public var fontColor: SRColor
    public var fontParams: SRFontParamsValue
}
