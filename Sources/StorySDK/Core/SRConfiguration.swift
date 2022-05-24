//
//  SRConfiguration.swift
//  StorySDK
//
//  Created by Aleksei Cherepanov on 12.05.2022.
//

import UIKit

public struct SRConfiguration {
    public var language = "en"
    public var sdkId: String?
    public var userId: String?
    
    /// Duration in seconds for each story in a group
    public var storyDuration: TimeInterval
    /// Show title for stories
    public var needShowTitle: Bool
    /// Show stories in full screen
    public var needFullScreen: Bool
    /// Filled story progress color
    public var progressColor: UIColor
    
    /// Available languages for the app.
    /// Try to load all if it's empty
    public private(set) var languages: Set<String> = .init()
    /// Default language choosed for the app
    public private(set) var defaultLanguage: String = "en"
    
    public init(language: String = "en",
                sdkId: String? = nil,
                userId: String? = nil,
                storyDuration: TimeInterval = 6.0,
                needShowTitle: Bool = false,
                needFullScreen: Bool = true,
                progressColor: UIColor = .white
    ) {
        self.language = language
        self.sdkId = sdkId
        self.userId = userId
        self.storyDuration = storyDuration
        self.needShowTitle = needShowTitle
        self.needFullScreen = needFullScreen
        self.progressColor = progressColor
    }
    
    mutating func update(localization: AppLocalization) {
        languages = .init(localization.languages)
        defaultLanguage = localization.defaultLocale
    }
    
    func fetchCurrentLanguage() -> String {
        languages.contains(language) ? language : defaultLanguage
    }
}
