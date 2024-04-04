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
        if let sdkId = configuration.sdkId {
            do {
                if let bundlePath = Bundle.main.path(forResource: sdkId,
                                                     ofType: "json"),
                    let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                    let result = try NetworkManager.decode(SRStoryApp.self, from: jsonData, response: nil, error: nil)
                    updateApp(result)
                    completion(.success(result))
                    
                    return
                }
            } catch {
                logger.error(error)
            }
        }
        
        network.getApp { [weak self] result in
            if case .success(let app) = result { self?.updateApp(app) }
            completion(result)
        }
    }
}

// MARK: - Network for Groups

extension StorySDK {
    public func getGroups(from: String? = nil, to: String? = nil, completion: @escaping (Result<[SRStoryGroup], Error>) -> Void) {
        
//        if let sdkId = configuration.sdkId {
//            do {
//                if let bundlePath = Bundle.main.path(forResource: sdkId + "-groups",
//                                                     ofType: "json"),
//                    let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
//                    let result = try NetworkManager.decode([SRStoryGroup].self, from: jsonData, response: nil, error: nil)
//                    completion(.success(result))
//
//                    return
//                }
//            } catch {
//                logger.error(error)
//            }
//        }
        
        network.getGroups(from: from, to: to, completion: completion)
    }
    
    public func getGroup(groupId: String, from: String? = nil, to: String? = nil, completion: @escaping (Result<SRStoryGroup, Error>) -> Void) {
        network.getGroup(groupId: groupId, completion: completion)
    }
}

// MARK: - Network for Stories

extension StorySDK {
    public func getStories(_ group: SRStoryGroup, completion: @escaping (Result<[SRStory], Error>) -> Void) {
        if let bundlePath = Bundle.main.path(forResource: group.id, ofType: "json") {
            logger.error("Found cached group")
            do {
                if let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                    let result = try NetworkManager.decode([SRStory].self, from: jsonData, response: nil, error: nil)
                    let activeStories = result.filter { $0.readyToShow() }
                    completion(.success(activeStories))
                    
                    //completion(.success(result))
                    
                    return
                }
            } catch {
                logger.error(error)
            }
        } else {
            logger.error("Not found")
        }
        
        network.getStories(groupId: group.id, completion: completion)
    }
}

// MARK: - Statistic

extension StorySDK {
    func sendStatistic(_ reaction: SRStatistic, completion: @escaping (Result<Bool, Error>) -> Void) {
        var reaction = reaction
        reaction.locale = configuration.fetchCurrentLanguage()
        reaction.userId = userDefaults.userId
        reaction.value = reaction.value ?? ""
        network.sendStatistic(reaction: reaction, completion: completion)
    }
}
