//
//  SREmojiReactionWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public struct SREmojiReactionWidget: Decodable {
    public var emoji: [SREmojiValue]
    public var color: SRThemeColor
}
