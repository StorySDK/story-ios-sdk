//
//  ChooseAnswerWidget.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct ChooseAnswerWidget {
    let text: String
    let color: String
    let markCorrectAnswer: Bool
    let answers: [AnswerValue]
    let correct: String
    
    public init() {
        self.text = ""
        self.color = "FFFFFF"
        self.markCorrectAnswer = false
        self.answers = [AnswerValue]()
        self.correct = "NO"
    }
    
    public init(from dict: Json) {
        self.text = dict["text"] as? String ?? ""
        self.color = dict["color"] as? String ?? "FFFFFF"
        self.markCorrectAnswer = dict["markCorrectAnswer"] as? Bool ?? false
        var answers = [AnswerValue]()
        if let array = dict["answers"] as? NSArray {
            for answerDict in array {
                let answer = AnswerValue(from: answerDict as! Json)
                answers.append(answer)
            }
        }
        self.answers = answers
        self.correct = dict["correct"] as? String ?? "NO"
    }
}
