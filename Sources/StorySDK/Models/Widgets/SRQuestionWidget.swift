//
//  QuestionWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public struct SRQuestionWidget: Decodable {
    public var question: String
    public var confirm: String
    public var decline: String
    public var color: String
}
