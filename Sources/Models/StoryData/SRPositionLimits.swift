//
//  SRPositionLimits.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public struct SRPositionLimits: Decodable {
    public var minWidth: Double?
    public var minHeight: Double?
    public var isResizableX: Bool
    public var isResizableY: Bool
    public var isRotatable: Bool
    public var keepRatio: Bool?
}
