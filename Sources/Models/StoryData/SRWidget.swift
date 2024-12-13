//
//  SRWidget.swift
//  
//
//  Created by Aleksei Cherepanov on 23.05.2022.
//

import Foundation

public struct SRWidget: Decodable {
    public var id: String
    public var positionLimits: SRPositionLimits
    public var positionByResolutions: SRPositionByResolutions
    public var content: SRWidgetContent
    
    enum CodingKeys: String, CodingKey {
        case id, position, positionLimits, positionByResolutions, content
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        
        positionLimits = try container.decode(SRPositionLimits.self, forKey: .positionLimits)
        positionByResolutions = try container.decode(SRPositionByResolutions.self, forKey: .positionByResolutions)
        content = try container.decode(SRWidgetContent.self, forKey: .content)
    }
    
    public func getWidgetPosition(storySize: CGSize) -> SRPosition {
//        if CGSize.isSmallStories(storySize: storySize) {
//            return positionByResolutions.res360x640!
//        } else {
//            return positionByResolutions.res360x780!
//        }
        return positionByResolutions.res360x780!
    }
}
