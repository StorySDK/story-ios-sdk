//
//  SRNetwork.swift
//  StorySDK
//
//  Created by Aleksei Cherepanov on 12.05.2022.
//

import Foundation

// MARK: - Network for App

extension StorySDK {
    public func getApps(completion: @escaping (Result<StoryApp, Error>) -> Void) {
        network.getApps { result in
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
        }
    }
    
    public func getApp(appId: String, completion: @escaping (Result<StoryApp, Error>) -> Void) {
        network.getApp(appId: appId, completion: completion)
    }
}

// MARK: - Network for Groups

extension StorySDK {
    public func getGroups(from: String? = nil, to: String? = nil, statistic: Bool? = nil, completion: @escaping (Result<[StoryGroup], Error>) -> Void) {
        network.getApps { [weak self] result in
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
        }
    }
    
    public func getGroups(appId: String, from: String? = nil, to: String? = nil, statistic: Bool? = nil, completion: @escaping (Result<[StoryGroup], Error>) -> Void) {
        network.getGroups(appId: appId, statistic: statistic, from: from, to: to, completion: completion)
    }
    
    public func getGroup(appId: String, groupId: String, from: String? = nil, to: String? = nil, statistic: Bool? = nil, completion: @escaping (Result<StoryGroup, Error>) -> Void) {
        network.getGroup(appId: appId, groupId: groupId, statistic: statistic, completion: completion)
    }
}

// MARK: - Network for Stories

extension StorySDK {
    public func getStories(_ group: StoryGroup, statistic: Bool? = nil, completion: @escaping (Result<[Story], Error>) -> Void) {
        getStories(appId: group.appId, groupId: group.id, statistic: statistic, completion: completion)
    }
    
    public func getStories(appId: String, groupId: String, statistic: Bool? = nil, completion: @escaping (Result<[Story], Error>) -> Void) {
        network.getStories(appId: appId, groupId: groupId, statistic: statistic, completion: completion)
    }
}

// MARK: - Statistic

extension StorySDK {
    func sendStatistic(_ reaction: Data, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        network.sendStatistic(reaction: reaction, completion: completion)
    }
}
