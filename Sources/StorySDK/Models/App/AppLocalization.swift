//
//  AppLocalization.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 09.04.2022.
//

import UIKit

public struct AppLocalization: Codable {
    public let default_locale: String
    public let languages: [String]
    
    enum CodingKeys: String, CodingKey {
        case default_locale = "default"
        case languages
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.default_locale = try container.decode(String.self, forKey: .default_locale)
        self.languages = try container.decode([String].self, forKey: .languages)
    }

}
