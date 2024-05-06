//
//  SRQuizMultipleImageWidget.swift
//  StorySDK
//
//  Created by Igor Efremov on 09.05.2023.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public struct SRQuizMultipleImageWidget: Decodable {
    public var title: String
    public var answers: [SRImageAnswer]
    public var titleFont: SRAnswersFont
    public var answersFont: SRAnswersFont
}
