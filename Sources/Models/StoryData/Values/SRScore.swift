//
//  SRScore.swift
//  StorySDK
//
//  Created by Ingvarr Alef on 21.05.2023.
//

import Foundation

public struct SRScore: Decodable {
    public var letter: String?
    public var points: Int?
    
    enum CodingKeys: String, CodingKey {
        case letter, points
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        letter = try container.decode(String.self, forKey: .letter)
        let pointsStringValue = try? container.decode(String.self, forKey: .points)
        if let value = pointsStringValue {
            points = Int(value)
        } else {
            let pointsIntValue = try? container.decode(Int.self, forKey: .points)
            points = pointsIntValue
        }
    }
}
