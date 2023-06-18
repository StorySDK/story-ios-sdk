//
//  SRWidget.swift
//  
//
//  Created by Aleksei Cherepanov on 23.05.2022.
//

import Foundation

public struct SRWidget: Decodable {
    public var id: String
    public var position: SRPosition
    public var positionLimits: SRPositionLimits
    public var content: SRWidgetContent
    
    enum CodingKeys: String, CodingKey {
        case id, position, positionLimits, content
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        position = try container.decode(SRPosition.self, forKey: .position)
        positionLimits = try container.decode(SRPositionLimits.self, forKey: .positionLimits)
        content = try container.decode(SRWidgetContent.self, forKey: .content)
    }
}
