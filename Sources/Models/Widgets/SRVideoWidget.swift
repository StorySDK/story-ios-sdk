//
//  SRVideoWidget.swift
//  StorySDK
//
//  Created by Igor Efremov on 20.10.2023.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public struct SRVideoWidget: Decodable {
    public var videoUrl: URL?
}
