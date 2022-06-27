//
//  StorySDK.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 02.02.2022.
//

import Foundation
import os

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
    private(set) var logger: SRLogger = .init()
    var context = SRContext()
    let network = NetworkManager()
    let imageLoader: SRImageLoader
    var userDefaults: SRUserDefaults = SRMemoryUserDefaults()
    
    public init(configuration: SRConfiguration = .init(), imageLoader: SRImageLoader = StorySDK.imageLoader) {
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
    
    private func update(configuration: SRConfiguration) {
        network.setupAuthorization(configuration.sdkId)
        network.setupLanguage(configuration.fetchCurrentLanguage())
        if let sdkId = configuration.sdkId, let key = SRDiskUserDefaults.makeKey(sdkId: sdkId) {
            do {
                let newDefaults = try SRDiskUserDefaults(key: key, logger: logger)
                userDefaults = newDefaults
            } catch {
                print("StorySDK > Error:", error.localizedDescription)
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
