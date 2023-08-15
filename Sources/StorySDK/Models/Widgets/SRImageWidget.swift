//
//  SRImageWidget.swift
//  StorySDK
//
//  Created by Igor Efremov on 15.08.2023.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public struct SRImageWidget: Decodable {
    public var imageUrl: URL?
}
