//
//  SRStoryGroup.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 03.02.2022.
//

import Foundation

public enum SRStoryGroupType: String {
    case onboarding, group
    
    public static func <(lhs: SRStoryGroupType, rhs: SRStoryGroupType) -> Bool {
        return lhs == SRStoryGroupType.onboarding && rhs == SRStoryGroupType.group
    }
}

public struct SRStoryGroup: Decodable {
    public var id: String
    public var appId: String
    public var userId: String
    public var title: String
    public var imageUrl: URL?
    public var startTime: String
    public var endTime: String
    public var active: Bool
    public var type: String
    public var settings: SRStorySettings?
    public var createdAt: Date
    public var updatedAt: Date
}

extension SRStoryGroup: Comparable {
    public static func == (lhs: SRStoryGroup, rhs: SRStoryGroup) -> Bool {
        return lhs.id == rhs.id
    }
    
    public static func <(lhs: SRStoryGroup, rhs: SRStoryGroup) -> Bool {
        let lType = SRStoryGroupType(rawValue: lhs.type) ?? .group
        let rType = SRStoryGroupType(rawValue: rhs.type) ?? .group
        
        if lType < rType { return true }
        
        return lhs.createdAt < lhs.createdAt
    }
}
