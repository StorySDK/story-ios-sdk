//
//  SRPosition.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

import Foundation

public struct SRPosition: Decodable {
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double
    public var realWidth: Double
    public var realHeight: Double
    public var isHeightLocked: Bool
    public var rotate: Double
    
    public var origin: SROrigin
    
    enum CodingKeys: String, CodingKey {
        case x, y, width, height, realWidth, realHeight, rotate, isHeightLocked, origin
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        x = try container.decode(Double.self, forKey: .x)
        y = try container.decode(Double.self, forKey: .y)
        
        let width = try? container.decode(Double.self, forKey: .width)
        let height = try? container.decode(Double.self, forKey: .height)
        let realWidth = try container.decode(Double.self, forKey: .realWidth)
        let realHeight = try container.decode(Double.self, forKey: .realHeight)
        
        self.width = width ?? realWidth
        self.realWidth = realWidth
        self.height = height ?? realHeight
        self.realHeight = realHeight
        self.isHeightLocked = try container.decode(Bool?.self, forKey: .isHeightLocked) ?? false
         
        rotate = try container.decode(Double.self, forKey: .rotate)
        origin = try container.decode(SROrigin.self, forKey: .origin)
    }
}
