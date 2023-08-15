//
//  SliderWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public struct SRSliderWidget: Decodable {
    public var text: String?
    public var color: SRThemeColor
    public var emoji: SREmojiValue
    public var value: Double
}
