//
//  AppGroupView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 09.04.2022.
//

import UIKit

public struct AppGroupView: Codable {
    public let android: String
    public let web: String
    public let ios: AppGroupViewSettings
    public let react: String
}

public enum AppGroupViewSettings: String, Codable {
    case circle, square, rectangle, bigSquare
}
