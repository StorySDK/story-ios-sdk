//
//  SRCustomFields.swift
//  StorySDK
//
//  Created by Igor Efremov on 19.10.2023.
//

import Foundation

public struct SRCustomFields: Decodable {
    public var ios: String?
    
    enum CodingKeys: String, CodingKey {
        case ios
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ios = try container.decode(String.self, forKey: .ios)
    }
}
