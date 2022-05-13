//
//  StoryApp.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 03.02.2022.
//

import Foundation

public struct StoryApp: Codable {
    public let id: String
    public let userId: String
    public let title: String
    public let iosAppId: String
    public let androidAppId: String
    public let share: Bool
    public let sdkToken: String
    public let settings: AppSettings
    public let localization: AppLocalization
    public let createdAt: Date
    public let updatedAt: Date
}

public struct Instance: Codable {
    let instance: String
}
