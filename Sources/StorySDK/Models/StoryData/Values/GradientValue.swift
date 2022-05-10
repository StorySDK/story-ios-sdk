//
//  GradientValue.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

import UIKit

public struct GradientValue {
    let type: String
    let value: [String]
    
    public init() {
        self.type = ""
        self.value = [String]()
    }
    
    public init(from dict: Json) {
        self.type = dict["type"] as? String ?? ""
        var strings = [String]()
        if let array = dict["value"] as? NSArray {
            for result in array {
                strings.append(result as! String)
            }
        }

        self.value = strings
    }
}
