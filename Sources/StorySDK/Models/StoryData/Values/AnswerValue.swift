//
//  AnswerValue.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

import UIKit

public struct AnswerValue {
    let id: String
    let title: String
    
    public init() {
        self.id = ""
        self.title = ""
    }
    
    public init(from dict: Json) {
        self.id = dict["id"] as? String ?? ""
        self.title = dict["title"] as? String ?? ""
    }
}
