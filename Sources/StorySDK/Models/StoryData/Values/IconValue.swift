//
//  IconValue.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

import UIKit

public struct IconValue {
    let name: String
    
    public init() {
        self.name = ""
    }
    
    public init(from dict: Json) {
        self.name = dict["name"] as? String ?? ""
    }
}
