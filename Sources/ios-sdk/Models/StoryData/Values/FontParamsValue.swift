//
//  FontParamsValue.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

import UIKit

public struct FontParamsValue: Codable {
    public let style: String
    public let weight: Double
    
    public init() {
        self.style = ""
        self.weight = 0
    }
    
    public init(from dict: Json) {
        self.style = dict["style"] as? String ?? ""
        self.weight = dict["weight"] as? Double ?? 0
    }
}
