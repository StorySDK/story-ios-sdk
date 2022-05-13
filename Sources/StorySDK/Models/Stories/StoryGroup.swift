//
//  StoryGroup.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 03.02.2022.
//

import Foundation

public struct StoryGroup: Codable {
    public let id: String
    public let appId: String
    public let userId: String
    public let title: [String: String]
    public let imageUrl: [String: URL]
    public let startTime: String
    public let endTime: String
    public let statistic: StoreGroupStatistic?
    public let active: Bool
    public let createdAt: Date
    public let updatedAt: Date
    
    public func getTitle(locale: String, defaultLocale: String? = nil) -> String? {
        if let title = title[locale] { return title }
        guard let defaultLocale = defaultLocale else { return nil }
        return title[defaultLocale]
    }
    
    public func getImageURL(locale: String, defaultLocale: String? = nil) -> URL? {
        if let url = imageUrl[locale] { return url }
        guard let defaultLocale = defaultLocale else { return nil }
        return imageUrl[defaultLocale]
    }
}
