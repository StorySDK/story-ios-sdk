//
//  SRNetwork.swift
//  StorySDK
//
//  Created by Aleksei Cherepanov on 12.05.2022.
//

import Foundation

// MARK: - Network for App

extension StorySDK {
    public func getApp(completion: @escaping (Result<SRStoryApp, Error>) -> Void) {
        network.getApp { [weak self] result in
            if case .success(let app) = result { self?.updateApp(app) }
            completion(result)
        }
    }
}

// MARK: - Network for Groups

extension StorySDK {
    public func getGroups(from: String? = nil, to: String? = nil, completion: @escaping (Result<[SRStoryGroup], Error>) -> Void) {
        network.getGroups(from: from, to: to, completion: completion)
    }
    
    public func getGroup(groupId: String, from: String? = nil, to: String? = nil, completion: @escaping (Result<SRStoryGroup, Error>) -> Void) {
        network.getGroup(groupId: groupId, completion: completion)
    }
}

// MARK: - Network for Stories

extension StorySDK {
    public func getStories(_ group: SRStoryGroup, completion: @escaping (Result<[SRStory], Error>) -> Void) {
        network.getStories(groupId: group.id, completion: completion)
    }
}

// MARK: - Statistic

extension StorySDK {
    func sendStatistic(_ reaction: SRStatistic, completion: @escaping (Result<Bool, Error>) -> Void) {
        var reaction = reaction
        reaction.locale = configuration.fetchCurrentLanguage()
        reaction.userId = userDefaults.userId
        network.sendStatistic(reaction: reaction, completion: completion)
    }
}
