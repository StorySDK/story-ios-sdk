//
//  StorySDK.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 02.02.2022.
//

import Foundation

public final class StorySDK: NSObject {
    public static let shared = StorySDK()
    public static let imageLoader = SRImageLoader()
    public var configuration = SRConfiguration() {
        didSet { update(configuration: configuration) }
    }
    public private(set) var app: StoryApp?
    var context = SRContext()
    let network = NetworkManager()
    let imageLoader: SRImageLoader
    
    public init(configuration: SRConfiguration = .init(), imageLoader: SRImageLoader = StorySDK.imageLoader) {
        self.configuration = configuration
        self.imageLoader = imageLoader
        super.init()
        update(configuration: configuration)
    }
    
    func updateApp(_ app: StoryApp) {
        self.app = app
        configuration.update(localization: app.localization)
    }
    
    private func update(configuration: SRConfiguration) {
        network.setupAuthorization(configuration.sdkId)
        network.setupLanguage(configuration.fetchCurrentLanguage())
    }
}

struct SRContext {
    var defaultLocale: String?
}

let packageBundleId = "com.storysdk.framework"
