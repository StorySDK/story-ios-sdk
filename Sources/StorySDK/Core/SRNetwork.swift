//
//  SRNetwork.swift
//  StorySDK
//
//  Created by Aleksei Cherepanov on 12.05.2022.
//

import Foundation

// MARK: - Network for App

extension StorySDK {
    public func getApp(completion: @escaping (Result<StoryApp, Error>) -> Void) {
        network.getApp(completion: completion)
    }
}

// MARK: - Network for Groups

extension StorySDK {
    public func getGroups(from: String? = nil, to: String? = nil, statistic: Bool? = nil, completion: @escaping (Result<[StoryGroup], Error>) -> Void) {
        network.getGroups(from: from, to: to, statistic: statistic, completion: completion)
    }
    
    public func getGroup(groupId: String, from: String? = nil, to: String? = nil, statistic: Bool? = nil, completion: @escaping (Result<StoryGroup, Error>) -> Void) {
        network.getGroup(groupId: groupId, statistic: statistic, completion: completion)
    }
}

// MARK: - Network for Stories

extension StorySDK {
    public func getStories(_ group: StoryGroup, statistic: Bool? = nil, completion: @escaping (Result<[Story], Error>) -> Void) {
        network.getStories(groupId: group.id, statistic: statistic, completion: completion)
    }
}

// MARK: - Statistic

extension StorySDK {
    func sendStatistic(_ reaction: Data, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        network.sendStatistic(reaction: reaction, completion: completion)
    }
}
