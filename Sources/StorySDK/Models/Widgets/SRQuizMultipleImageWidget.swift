//
//  SRQuizMultipleImageWidget.swift
//  StorySDK
//
//  Created by Igor Efremov on 09.05.2023.
//

import UIKit

public struct SRQuizMultipleImageWidget: Decodable {
    public var title: String
    public var answers: [SRImageAnswer]
}
