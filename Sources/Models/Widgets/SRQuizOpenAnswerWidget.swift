//
//  SRQuizOpenAnswerWidget.swift
//  StorySDK
//
//  Created by Igor Efremov on 09.05.2023.
//

import Foundation

public struct SRQuizOpenAnswerWidget: Decodable {
    public var title: String
    public var fontFamily: String
    public var fontParams: SRFontParamsValue
    public var fontColor: SRColor
}
