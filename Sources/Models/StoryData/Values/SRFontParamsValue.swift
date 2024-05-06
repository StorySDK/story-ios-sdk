//
//  SRFontParamsValue.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public struct SRFontParamsValue: Codable {
    public var style: String
    public var weight: Double
}
