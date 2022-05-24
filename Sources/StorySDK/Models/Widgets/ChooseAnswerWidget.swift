//
//  ChooseAnswerWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import Foundation

public struct ChooseAnswerWidget: Decodable {
    let text: String
    let color: SRThemeColor?
    let markCorrectAnswer: Bool
    let answers: [AnswerValue]
    let correct: String
}

