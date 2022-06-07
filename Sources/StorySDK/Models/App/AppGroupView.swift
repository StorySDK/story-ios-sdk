//
//  AppGroupView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 09.04.2022.
//

import UIKit

public struct AppGroupView: Codable {
    public var android: String
    public var web: String
    public var ios: AppGroupViewSettings
    public var react: String
}

public enum AppGroupViewSettings: String, Codable {
    case circle, square, rectangle, bigSquare
}
