//
//  SRQuizMultipleImageWidget.swift
//  StorySDK
//
//  Created by Ingvarr Alef on 09.05.2023.
//

import UIKit

public struct SRQuizMultipleImageWidget: Decodable {
    public var title: String
    public var answers: [SRImageAnswer]
    public var answersFont: SRAnswersFont
}
