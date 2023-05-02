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
    public var updatedAt: Date
}
