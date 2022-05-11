//
//  StorySDK.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 02.02.2022.
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
    
    
    public init(language: String = "en",
                sdkId: String? = nil,
                userId: String? = nil,
                storyDuration: TimeInterval = 6.0,
                needShowTitle: Bool = false,
                needFullScreen: Bool = true,
                progressColor: UIColor = .blue
    ) {
        self.language = language
        self.sdkId = sdkId
        self.userId = userId
        self.storyDuration = storyDuration
        self.needShowTitle = needShowTitle
        self.needFullScreen = needFullScreen
        self.progressColor = progressColor
    }
}

public final class StorySDK: NSObject {
    public static let shared = StorySDK()
    public var configuration = SRConfiguration()
    
    public init(configuration: SRConfiguration = .init()) {
        self.configuration = configuration
        super.init()
    }
}

// MARK: - Network for App
extension StorySDK {
    public func getApps(completion: @escaping (Result<StoryApp, Error>) -> Void) {
        guard let sdkId = configuration.sdkId else {
            completion(.failure(SRError.sdkIdIsNill))
            return
        }
        NetworkManager.shared.getApps(sdkId, completion: { result in
            switch result {
            case .success(let apps):
                if let app = apps.first {
                    completion(.success(app))
                } else {
                    completion(.failure(SRError.noAppsToDisplay))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    public func getApp(appId: String, completion: @escaping (Result<StoryApp, Error>) -> Void) {
        guard let sdkId = configuration.sdkId else {
            completion(.failure(SRError.sdkIdIsNill))
            return
        }
        NetworkManager.shared.getApp(sdkId, appId: appId, completion: completion)
    }
}

// MARK: - Network for Groups
extension StorySDK {
    public func getGroups(from: String? = nil, to: String? = nil, statistic: Bool? = nil, completion: @escaping (Result<[StoryGroup], Error>) -> Void) {
        guard let sdkId = configuration.sdkId else {
            completion(.failure(SRError.sdkIdIsNill))
            return
        }
        NetworkManager.shared.getApps(sdkId, completion: { [weak self] result in
            switch result {
            case .success(let apps):
                if let id = apps.first?.id, let sdk = self {
                    sdk.getGroups(appId: id, from: from, to: to, statistic: statistic, completion: completion)
                } else {
                    completion(.failure(SRError.emptyResponse))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    public func getGroups(appId: String, from: String? = nil, to: String? = nil, statistic: Bool? = nil, completion: @escaping (Result<[StoryGroup], Error>) -> Void) {
        guard let sdkId = configuration.sdkId else {
            completion(.failure(SRError.sdkIdIsNill))
            return
        }
        NetworkManager.shared.getGroups(sdkId, appId: appId, statistic: statistic, from: from, to: to, completion: completion)
    }
    
    public func getGroup(appId: String, groupId: String, from: String? = nil, to: String? = nil, statistic: Bool? = nil, completion: @escaping (Result<StoryGroup, Error>) -> Void) {
        guard let sdkId = configuration.sdkId else {
            completion(.failure(SRError.sdkIdIsNill))
            return
        }
        NetworkManager.shared.getGroup(sdkId, appId: appId, groupId: groupId, statistic: statistic, completion: completion)
    }
}

// MARK: - Network for Stories
extension StorySDK {
    public func getStories(_ group: StoryGroup, statistic: Bool? = nil, completion: @escaping (Result<[Story], Error>) -> Void) {
        getStories(appId: group.app_id, groupId: group.id, statistic: statistic, completion: completion)
    }
    
    public func getStories(appId: String, groupId: String, statistic: Bool? = nil, completion: @escaping (Result<[Story], Error>) -> Void) {
        guard let sdkId = configuration.sdkId else {
            completion(.failure(SRError.sdkIdIsNill))
            return
        }
        NetworkManager.shared.getStories(sdkId, appId: appId, groupId: groupId, statistic: statistic, completion: completion)
    }
}

// MARK: - Statistic
extension StorySDK {
    func sendStatistic(_ reaction: Data, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let sdkId = configuration.sdkId else {
            completion(.failure(SRError.sdkIdIsNill))
            return
        }
        NetworkManager.shared.sendStatistic(sdkId, reaction: reaction, completion: completion)
    }
}

public enum SRError: Error, LocalizedError {
    case sdkIdIsNill
    case noAppsToDisplay
    case emptyResponse
    case serverError(String?)
    case wrongFormat
    case unknownError
    
    public var errorDescription: String? {
        switch self {
        case .sdkIdIsNill:
            return "SDK id is nil"
        case .noAppsToDisplay:
            return "You don't have apps to display"
        case .emptyResponse:
            return "Data is empty"
        case .serverError(let info):
            return info.map { "Error response: \($0)" } ?? "Error response"
        case .wrongFormat:
            return "Wrong response format"
        case .unknownError:
            return "Unknown error"
        }
    }
}
