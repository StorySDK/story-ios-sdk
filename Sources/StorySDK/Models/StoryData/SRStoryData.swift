//
//  SRStoryData.swift
//  
//
//  Created by Aleksei Cherepanov on 23.05.2022.
//

import Foundation

public struct SRStoryData: Decodable {
    //public var background: SRColor?
    public var background: BRColor?
    public var status: SRStoryStatus
    public var widgets: [SRWidget]
    public var startTime: TimeInterval
    public var endTime: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case background, status, widgets, startTime, endTime
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        background = try? container.decode(BRColor.self, forKey: .background)
        status = (try? container.decode(SRStoryStatus.self, forKey: .status)) ?? .invalid
        widgets = try container.decode([SRWidget].self, forKey: .widgets)
        
        let innerStartTime = try? container.decode(String.self, forKey: .startTime)
        let innerEndTime = try? container.decode(String.self, forKey: .endTime)
        
        startTime = TimeInterval(innerStartTime ?? "") ?? 0
        endTime = TimeInterval(innerEndTime ?? "") ?? TimeInterval.infinity
    }
    
    public func readyToShow() -> Bool {
        let timestamp = TimeInterval(Date().timeIntervalSince1970 * 1000)
        return (startTime < timestamp) && (timestamp < endTime)
    }
}

public enum SRStoryStatus: String, Decodable {
    case draft, active, invalid
}
