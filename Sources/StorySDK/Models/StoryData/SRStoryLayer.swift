//
//  SRStoryLayer.swift
//  
//
//  Created by Igor Efremov on 28.04.2023.
//

import Foundation

public struct SRStoryLayer: Decodable {
    public var layersGroupId: String
    public var positionInGroup: Int
    public var score: SRLayerScore?
    public var isDefaultLayer: Bool
    
    enum CodingKeys: String, CodingKey {
        case layersGroupId, positionInGroup, score, isDefaultLayer
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        layersGroupId = try container.decode(String.self, forKey: .layersGroupId)
        positionInGroup = try container.decode(Int.self, forKey: .positionInGroup)
        score = try? container.decode(SRLayerScore.self, forKey: .score)
        isDefaultLayer = try container.decode(Bool.self, forKey: .isDefaultLayer)
    }
}
