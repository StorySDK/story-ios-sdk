//
//  SRQuizOneAnswerWidget.swift
//  StorySDK
//
//  Created by Igor Efremov on 04.05.2023.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public struct SRQuizOneAnswerWidget: Decodable {
    public var title: String
    public var answers: [SRAnswerValue]
    public var titleFont: SRAnswersFont
    public var answersFont: SRAnswersFont
}
