//
//  SRSwipeUpWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public struct SRSwipeUpWidget: Decodable {
    public var text: String
    public var opacity: Double
    public var iconSize: Double
    public var fontSize: Double
    public var fontFamily: String
    public var fontParams: SRFontParamsValue
    public var color: SRColor
    public var url: String
    public var icon: SRIcon
}
