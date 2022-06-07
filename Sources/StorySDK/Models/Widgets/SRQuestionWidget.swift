//
//  QuestionWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct SRQuestionWidget: Decodable {
    public var question: String
    public var confirm: String
    public var decline: String
    public var color: String
}
