//
//  SRAppSettings.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 09.04.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public struct SRAppSettings: Codable {
    let groupView: SRAppGroupView
}
