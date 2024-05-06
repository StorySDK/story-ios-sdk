//
//  SRTalkAboutWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public struct SRTalkAboutWidget: Decodable {
    public var text: String
    public var image: URL?
    public var color: SRThemeColor
    public var fontFamily: String
    public var fontParams: SRFontParamsValue
}
