//
//  AppLocalization.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 09.04.2022.
//

import UIKit

public struct AppLocalization: Codable {
    public let defaultLocale: String
    public let languages: [String]
    
    enum CodingKeys: String, CodingKey {
        case defaultLocale = "default"
        case languages
    }
}
