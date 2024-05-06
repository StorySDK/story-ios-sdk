//
//  SRVideoWidget.swift
//  StorySDK
//
//  Created by Ingvarr Alef on 20.10.2023.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public struct SRVideoWidget: Decodable {
    public var videoUrl: URL?
}
