//
//  StorySDK.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 02.02.2022.
//

import Foundation

public final class StorySDK: NSObject {
    public static let shared = StorySDK()
    public var configuration = SRConfiguration() {
        didSet { update(configuration: configuration) }
    }
    var context = SRContext()
    let network = NetworkManager()
    
    public init(configuration: SRConfiguration = .init()) {
        self.configuration = configuration
        super.init()
        update(configuration: configuration)
    }
    
    private func update(configuration: SRConfiguration) {
        network.setupAuthorization(configuration.sdkId)
    }
}

struct SRContext {
    var defaultLocale: String?
}
