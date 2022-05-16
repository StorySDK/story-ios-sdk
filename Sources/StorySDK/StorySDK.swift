//
//  StorySDK.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 02.02.2022.
//

import Foundation

public final class StorySDK: NSObject {
    public static let shared = StorySDK()
    public static let imageLoader = SRImageLoader(cache: MemoryImageCache())
    public var configuration = SRConfiguration() {
        didSet { update(configuration: configuration) }
    }
    var context = SRContext()
    let network = NetworkManager()
    let imageLoader = SRImageLoader(cache: MemoryImageCache())
    
    public init(configuration: SRConfiguration = .init(), imageLoader: SRImageLoader = StorySDK.imageLoader) {
        self.configuration = configuration
        super.init()
        update(configuration: configuration)
    }
    
    private func update(configuration: SRConfiguration) {
        network.setupAuthorization(configuration.sdkId)
        network.setupLanguage(configuration.language)
    }
}

struct SRContext {
    var defaultLocale: String?
}
