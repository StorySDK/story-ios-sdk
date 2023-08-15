//
//  SROrigin.swift
//  StorySDK
//
//  Created by Ingvarr Alef on 15.08.2023.
//

import Foundation

public struct SROrigin: Decodable {
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double
    
    enum CodingKeys: String, CodingKey {
        case x, y, width, height
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        x = try container.decode(Double.self, forKey: .x)
        y = try container.decode(Double.self, forKey: .y)
        width = try container.decode(Double.self, forKey: .width)
        height = try container.decode(Double.self, forKey: .height)
    }
}
