//
//  WidgetPosition.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

import UIKit

public struct WidgetPosition {
    public let x: Double
    public let y: Double
    public let width: SizeType
    public let height: SizeType
    public let realWidth: Double?
    public let realHeight: Double?
    public let rotate: Double
    
    public init() {
        self.x = 0
        self.y = 0
        self.realWidth = 0
        self.realHeight = 0
        self.width = SizeType.double(0)
        self.height = SizeType.double(0)
        self.rotate = 0
    }
    
    public init(from dict: Json) {
        self.x = dict["x"] as? Double ?? 0
        self.y = dict["y"] as? Double ?? 0
        self.realWidth = dict["realWidth"] as? Double ?? 0
        self.realHeight = dict["realHeight"] as? Double ?? 0
        let w = dict["width"]
        if w is Double {
            self.width = SizeType.double(w as! Double)
        } else if w is String {
            self.width = SizeType.string(w as! String)
        } else {
            width = SizeType.double(0)
        }
        let h = dict["height"]
        if h is Double {
            self.height = SizeType.double(h as! Double)
        } else if h is String {
            self.height = SizeType.string(h as! String)
        } else {
            self.height = SizeType.double(0)
        }
        self.rotate = dict["rotate"] as? Double ?? 0
    }
}
