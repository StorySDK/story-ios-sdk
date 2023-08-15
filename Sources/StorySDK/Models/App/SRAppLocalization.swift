//
//  SRAppLocalization.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 09.04.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public struct SRAppLocalization: Codable {
    public var defaultLocale: String
    public var languages: [String]
    
    enum CodingKeys: String, CodingKey {
        case defaultLocale = "default"
        case languages
    }
}
