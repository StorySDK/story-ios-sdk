//
//  WidgetPositionLimits.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

import UIKit

public struct WidgetPositionLimits {
//    public let minX: Double?
//    public let minY: Double?
//    public let maxX: Double?
//    public let maxY: Double?
    public let minWidth: Double?
    public let minHeight: Double?
//    public let maxHeight: Double?
//    public let maxWidth: Double?
    public let keepRatio: Bool?
    public let ratioIndex: Double?
//    public let isAutoHeight: Bool?
//    public let isAutoWidth: Bool?
//    public let isResizableX: Bool
//    public let isResizableY: Bool
//    public let isRotatable: Bool

    public init() {
        self.minWidth = 0
        self.minHeight = 0
        self.keepRatio = false
        self.ratioIndex = 0
    }
    
    public init(from dict: Json) {
        self.minWidth = dict["minWidth"] as? Double ?? 0
        self.minHeight = dict["minHeight"] as? Double ?? 0
        self.keepRatio = dict["keepRatio"] as? Bool ?? false
        self.ratioIndex = dict["ratioIndex"] as? Double ?? 0
    }
}
