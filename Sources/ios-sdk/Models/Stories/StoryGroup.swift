//
//  StoryGroup.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 03.02.2022.
//

import Foundation

public struct StoryGroup: Codable {
    public let id: String
    public let app_id: String
    public let user_id: String
    public let title: [String: String]
    public let image_url: [String: String]
    public let start_time: String
    public let end_time: String
    public let statistic: StoreGroupStatistic?
    public let active: Bool
    public let created_at: String
    public let updated_at: String
    
    public func getTitle() -> String {
        if title.keys.contains(StorySDK.deviceLanguage) {
            return title[StorySDK.deviceLanguage]!
        }
        else {
            return title[StorySDK.defaultLanguage]!
        }
    }
    
    public func getImageURL() -> String {
        if image_url.keys.contains(StorySDK.deviceLanguage) {
            return image_url[StorySDK.deviceLanguage]!
        }
        else {
            return image_url[StorySDK.defaultLanguage]!
        }
    }
}
