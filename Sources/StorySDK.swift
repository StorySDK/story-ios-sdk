//
//  StorySDK.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 02.02.2022.
//

import Foundation
import os

private(set) var logger: SRLogger = .init()

public final class StorySDK: NSObject {
    public static let shared = StorySDK()
    public static let imageLoader = SRImageLoader(logger: .init())
    public var configuration = SRConfiguration() {
        didSet { update(configuration: configuration) }
    }
    public private(set) var app: SRStoryApp?
    public var logLevel: OSLogType {
        get { logger.logLevel }
        set { logger.logLevel = newValue }
    }
    
    var context = SRContext()
    
    lazy var network: NetworkManager = {
       return NetworkManager(baseUrl: configuration.sdkAPIUrl)
    }()
    
    let imageLoader: SRImageLoader
    var userDefaults: SRUserDefaults = SRMemoryUserDefaults()
    
    public let debugMode = false
    
    public init(configuration: SRConfiguration = .init(),
                imageLoader: SRImageLoader = StorySDK.imageLoader) {
        self.configuration = configuration
        self.imageLoader = imageLoader
        super.init()
        update(configuration: configuration)
    }
    
    public convenience init(sdkId: String) {
        self.init(configuration: .init(sdkId: sdkId))
    }
    
    func updateApp(_ app: SRStoryApp) {
        self.app = app
        configuration.update(localization: app.localization)
    }
    
    func resetLanguageToDefault() {
        network.setupLanguage(configuration.defaultLanguage)
    }
    
    private func update(configuration: SRConfiguration) {
        network.setupBaseUrl(configuration.sdkAPIUrl)
        network.setupAuthorization(configuration.sdkId)
        network.setupLanguage(configuration.fetchCurrentLanguage())
        if let sdkId = configuration.sdkId, let key = SRDiskUserDefaults.makeKey(sdkId: sdkId) {
            do {
                let newDefaults = try SRDiskUserDefaults(key: key, logger: logger)
                userDefaults = newDefaults
            } catch {
                logger.error(error)
                userDefaults = SRMemoryUserDefaults()
            }
        } else {
            userDefaults = SRMemoryUserDefaults()
        }
    }
}

struct SRContext {
    var defaultLocale: String?
}

let packageBundleId = "com.storysdk.framework"
