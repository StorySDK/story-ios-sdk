//
//  EmojiValue.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

import UIKit

public struct EmojiValue {
    public let name: String
    public let unicode: String
    
    public init() {
        self.name = ""
        self.unicode = ""
    }
    
    public init(from dict: Json) {
        self.name = dict["name"] as? String ?? ""
        self.unicode = dict["unicode"] as? String ?? ""
    }
}
