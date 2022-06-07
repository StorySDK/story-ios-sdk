//
//  StoryApp.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 03.02.2022.
//

import Foundation

public struct StoryApp: Codable {
    public var id: String
    public var userId: String
    public var title: String
    public var iosAppId: String
    public var androidAppId: String
    public var share: Bool
    public var sdkToken: String
    public var settings: AppSettings
    public var localization: AppLocalization
    public var createdAt: Date
    public var updatedAt: Date
}

public struct Instance: Codable {
    let instance: String
}
