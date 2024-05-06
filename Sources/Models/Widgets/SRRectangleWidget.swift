//
//  SRRectangleWidget.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 05.02.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public struct SRRectangleWidget: Decodable {
    public var fillColor: SRColor?
    public var fillBorderRadius: Double
    public var fillOpacity: Double
    public var widgetOpacity: Double
    public var strokeThickness: Double
    public var strokeColor: SRColor?
    public var strokeOpacity: Double
    public var hasBorder: Bool
}
