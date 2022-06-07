//
//  SRSizeType.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

import UIKit

public enum SRSizeType: Decodable {
    case double(Double), string(String)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else {
            let value = try container.decode(String.self)
            self = .string(value)
        }
    }
}
