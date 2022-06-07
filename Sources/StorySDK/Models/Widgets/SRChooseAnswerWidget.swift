//
//  SRChooseAnswerWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import Foundation

public struct SRChooseAnswerWidget: Decodable {
    public var text: String
    public var color: SRThemeColor?
    public var markCorrectAnswer: Bool
    public var answers: [SRAnswerValue]
    public var correct: String
}

