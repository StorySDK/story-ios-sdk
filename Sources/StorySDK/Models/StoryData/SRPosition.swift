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
    public var rotate: Double
    
    public var origin: SROrigin
    
    enum CodingKeys: String, CodingKey {
        case x, y, width, height, realWidth, realHeight, rotate, origin
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        x = try container.decode(Double.self, forKey: .x)
        y = try container.decode(Double.self, forKey: .y)
        width = try container.decode(Double.self, forKey: .width)
        height = try container.decode(Double.self, forKey: .height)
        realWidth = try container.decode(Double.self, forKey: .realWidth)
        realHeight = try container.decode(Double.self, forKey: .realHeight)
        rotate = try container.decode(Double.self, forKey: .rotate)
        
        origin = try container.decode(SROrigin.self, forKey: .origin)
    }
}
