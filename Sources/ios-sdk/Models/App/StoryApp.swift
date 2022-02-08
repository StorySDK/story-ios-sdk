//
//  StoryApp.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 03.02.2022.
//

import Foundation

public struct StoryApp: Codable {
    public let id: String
    public let user_id: String
    public let title: String
    public let ios_app_id: String
    public let android_app_id: String
    public let share: Bool
    public let sdk_token: String
    public let settings: AppSettings
//    let setting_ios: [String: Any]
//    let setting_android: Json
    public let localization: AppLocalization
    public let created_at: String
    public let updated_at: String
}

public struct Instance: Codable {
    let instance: String
}
