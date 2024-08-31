//
//  SRMetadata.swift
//  StorySDK
//
//  Created by Ingvarr Alef on 31.08.2024.
//

import Foundation

public struct SRMetadata: Decodable {
    public var duration: CGFloat?
    
    enum CodingKeys: String, CodingKey {
        case duration
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        duration = try? container.decode(CGFloat.self, forKey: .duration)
    }
}
