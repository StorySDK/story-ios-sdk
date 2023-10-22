//
//  SRPositionByResolutions.swift
//  
//
//  Created by Ingvarr Alef on 09/09/2023.
//

import Foundation

public struct SRPositionByResolutions: Decodable {
    public var res360x640: SRPosition?
    
    enum CodingKeys: String, CodingKey {
        case res360x640 = "360x640"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        res360x640 = try? container.decode(SRPosition.self, forKey: .res360x640)
    }
}
