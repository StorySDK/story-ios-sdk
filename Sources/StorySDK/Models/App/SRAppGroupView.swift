//
//  SRAppGroupView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 09.04.2022.
//

import UIKit

public struct SRAppGroupView: Codable {
//    public var android: String
//    public var web: String
    public var ios: SRAppGroupViewSettings
//    public var react: String
    
    enum CodingKeys: String, CodingKey {
        case ios
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ios = (try? container.decode(SRAppGroupViewSettings.self, forKey: .ios)) ?? .circle
    }
}

public enum SRAppGroupViewSettings: String, Codable {
    case circle, square, rectangle, bigSquare
}
