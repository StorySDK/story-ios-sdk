//
//  StoryGroup.swift
//  StorySDK
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
    
    public func getTitle(locale: String) -> String? {
        title[locale] ?? title["en"]
    }
    
    public func getImageURL(locale: String) -> String? {
        image_url[locale] ?? image_url["en"]
    }
}
