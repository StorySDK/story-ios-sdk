//
//  SRConfiguration.swift
//  StorySDK
//
//  Created by Aleksei Cherepanov on 12.05.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public struct SRConfiguration {
    public var language = "en"
    public var sdkId: String?
    public var sdkAPIUrl: String
    
    /// Duration in seconds for each story in a group
    public var storyDuration: TimeInterval
    /// Show title for stories
    public var needShowTitle: Bool
    /// Filled story progress color
    public var progressColor: StoryColor
    
    public var onboardingFilter: Bool
    
    public var loader: SRLoader = SRDefaultLoader()
    
    /// Available languages for the app.
    /// Try to load all if it's empty
    public private(set) var languages: Set<String> = .init()
    /// Default language choosed for the app
    public private(set) var defaultLanguage: String = "en"
    
    #if STAGE
    private static let SDK_API_URL = "https://api.diffapp.link/sdk/v1/"
    #else
    private static let SDK_API_URL = "https://api.storysdk.com/sdk/v1/"
    #endif
    
    public init(language: String = "en",
                sdkId: String? = nil,
                sdkAPIUrl: String? = nil,
                storyDuration: TimeInterval = 6.0,
                needShowTitle: Bool = false,
                progressColor: StoryColor = .init(white: 1, alpha: 1),
                onboardingFilter: Bool = false
    ) {
        self.language = language
        self.sdkId = sdkId
        self.sdkAPIUrl = sdkAPIUrl ?? SRConfiguration.SDK_API_URL
        self.storyDuration = storyDuration
        self.needShowTitle = needShowTitle
        self.progressColor = progressColor
        self.onboardingFilter = onboardingFilter
    }
    
    mutating func update(localization: SRAppLocalization) {
        languages = .init(localization.languages)
        defaultLanguage = localization.defaultLocale
    }
    
    func fetchCurrentLanguage() -> String {
        languages.contains(language) ? language : defaultLanguage
    }
}
