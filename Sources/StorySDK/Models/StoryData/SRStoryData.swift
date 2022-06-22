//
//  SRStoryData.swift
//  
//
//  Created by Aleksei Cherepanov on 23.05.2022.
//

import Foundation

public struct SRStoryData: Decodable {
    public var background: SRColor?
    public var status: SRStoryStatus
    public var widgets: [SRWidget]
    
    enum CodingKeys: String, CodingKey {
        case background, status, widgets
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        background = try? container.decode(SRColor.self, forKey: .background)
        status = (try? container.decode(SRStoryStatus.self, forKey: .status)) ?? .invalid
        widgets = try container.decode([SRWidget].self, forKey: .widgets)
    }
}

public enum SRStoryStatus: String, Decodable {
    case draft, active, invalid
}
