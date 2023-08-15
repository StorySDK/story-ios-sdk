//
//  SRAnswerValue.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public struct SRAnswerValue: Decodable {
    public var id: String
    public var title: String
    public var emoji: SREmojiValue?
    public var score: SRScore?
}
