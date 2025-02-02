//
//  SRStoryData.swift
//  
//
//  Created by Aleksei Cherepanov on 23.05.2022.
//

import Foundation

public struct SRStoryData: Decodable {
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
        guard status == .active else { return false }
        
        let timestamp = TimeInterval(Date().timeIntervalSince1970 * 1000)
        return (startTime < timestamp) && (timestamp < endTime)
    }
    
    public var duration: TimeInterval {
        let defaultDuration = StorySDK.shared.configuration.storyDuration
        var result: TimeInterval = defaultDuration
        
        guard let background = background else { return defaultDuration }
        
        switch background {
        case .video(let video, _):
            result = video.metadata?.duration ?? defaultDuration
        default:
            break
        }
        
        return result + 0.3
    }
}

public enum SRStoryStatus: String, Decodable {
    case draft, active, invalid
}
