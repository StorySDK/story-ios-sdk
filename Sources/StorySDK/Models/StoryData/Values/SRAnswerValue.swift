//
//  SRAnswerValue.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

import UIKit

public struct SRAnswerValue: Decodable {
    public var id: String
    public var title: String
    public var emoji: SREmojiValue?
}
