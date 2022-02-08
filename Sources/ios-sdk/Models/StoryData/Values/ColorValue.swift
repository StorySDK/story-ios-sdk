//
//  ColorValue.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

import UIKit

///Story color definition
///
///Type: possible variants:
///-
public struct ColorValue {
    let type: String
    let value: String
    
    public init() {
        self.type = ""
        self.value = ""
    }
    
    public init(from dict: Json) {
        self.type = dict["type"] as? String ?? ""
        self.value = dict["value"] as? String ?? ""
    }
}
