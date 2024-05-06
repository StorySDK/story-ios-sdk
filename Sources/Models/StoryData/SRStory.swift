//
//  SRStory.swift
//  
//
//  Created by Aleksei Cherepanov on 23.05.2022.
//

import Foundation

public struct SRStory: Decodable {
    public var id: String
    public var creatorId: String
    public var groupId: String
    public var position: Int
    public var storyData: SRStoryData?
    public var layerData: SRStoryLayer?
    public var createdAt: Date
    public var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, creatorId, groupId, position, storyData, layerData, createdAt, updatedAt
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        creatorId = try container.decode(String.self, forKey: .creatorId)
        groupId = try container.decode(String.self, forKey: .groupId)
        position = try container.decode(Int.self, forKey: .position)
        
        storyData = try? container.decode(SRStoryData.self, forKey: .storyData)
        layerData = try? container.decode(SRStoryLayer.self, forKey: .layerData)
        
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try? container.decode(Date.self, forKey: .updatedAt)
    }
    
    public func readyToShow() -> Bool {
        guard let storyData = storyData else { return false }
        
        return storyData.readyToShow()
    }
}
