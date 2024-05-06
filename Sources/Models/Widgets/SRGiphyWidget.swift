//
//  SRGiphyWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public struct SRGiphyWidget: Decodable {
    public var gif: URL
    public var widgetOpacity: Double
    public var borderRadius: Double
}
