//
//  SRQuizRateWidget.swift
//  StorySDK
//
//  Created by Igor Efremov on 02.06.2023.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public struct SRQuizRateWidget: Decodable {
    public var title: String
}
