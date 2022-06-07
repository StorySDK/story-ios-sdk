//
//  QuestionWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

import UIKit

public struct QuestionWidget: Decodable {
    let question: String
    let confirm: String
    let decline: String
    let color: String
}
