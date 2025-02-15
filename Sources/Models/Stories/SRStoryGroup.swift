//
//  SRStoryGroup.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 03.02.2022.
//

import Foundation

public enum SRStoryGroupType: String {
    case onboarding, group, unknown
    
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
    public var startTime: TimeInterval
    public var endTime: TimeInterval
    public var active: Bool
    public var type: SRStoryGroupType
    public var settings: SRStorySettings?
    public var createdAt: Date
    public var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, appId, userId, title, imageUrl, startTime, endTime, active, type, settings, createdAt, updatedAt
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        appId = try container.decode(String.self, forKey: .appId)
        userId = try container.decode(String.self, forKey: .userId)
        title = try container.decode(String.self, forKey: .title)
        imageUrl = try? container.decode(URL.self, forKey: .imageUrl)
       
        let innerStartTime = try container.decode(String.self, forKey: .startTime)
        let innerEndTime = try container.decode(String.self, forKey: .endTime)
        
        startTime = TimeInterval(innerStartTime) ?? 0
        endTime = TimeInterval(innerEndTime) ?? TimeInterval.infinity

        active = try container.decode(Bool.self, forKey: .active)
        let innerType = try container.decode(String.self, forKey: .type)
        
        type = SRStoryGroupType(rawValue: innerType) ?? .unknown
        settings = try? container.decode(SRStorySettings.self, forKey: .settings)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try? container.decode(Date.self, forKey: .updatedAt)
    }
    
    public func readyToShow() -> Bool {
        guard type != .unknown else { return false }
        
        if StorySDK.shared.configuration.onboardingFilter {
            if type == .onboarding {
                return false
            }
        }
        
        return active || type == .onboarding
    }
}

extension SRStoryGroup: Comparable {
    public static func == (lhs: SRStoryGroup, rhs: SRStoryGroup) -> Bool {
        return lhs.id == rhs.id
    }
    
    public static func <(lhs: SRStoryGroup, rhs: SRStoryGroup) -> Bool {
        let lType = lhs.type
        let rType = rhs.type
        
        if lType < rType { return true }
        
        return lhs.createdAt < lhs.createdAt
    }
}
