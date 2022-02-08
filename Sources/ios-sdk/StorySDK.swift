//
//  StorySDK.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 02.02.2022.
//

import UIKit

/**
 Базовый класс, обеспечивающий интерфейс
 */
public final class StorySDK: NSObject {
    private static var sdk_id = ""
    static var defaultLanguage = "en"
    static var deviceLanguage = "en"
    private var user_id = ""
    
    private override init() {
        super.init()
    }
    
    /// Initializer of StorySDK
    ///
    /// - Parameters:
    ///   - id: The corresponding SDK ID for the App
    ///   - userID: unique userID (for statistic , optional).
    ///   - preferredLanguage: preferred device language
    ///
    ///User ID is permanent allways while app is installed. If userID == nil, storySDK creates own unique userID
    public convenience init(_ id: String, userID: String? = nil, preferredLanguage: String) {
        self.init()
        
        StorySDK.sdk_id = id
        StorySDK.deviceLanguage = preferredLanguage
        
        //Установим уникальное имя пользователя
        if UserDefaults.standard.string(forKey: userIdKey) == nil {
            if let userID = userID {
                self.user_id = userID
            }
            else {
                self.user_id = UUID().uuidString
            }
            UserDefaults.standard.set(self.user_id, forKey: userIdKey)
        }
    }
    
    public func setDefaultLanguage(_ language: String) {
        StorySDK.defaultLanguage = language
    }
    
    public func changePrefferedLanguage(_ languange: String) {
        StorySDK.deviceLanguage = languange
    }
    
    ///Set timeline duration for each story in group
    ///
    ///- Parameters:
    ///- duration in seconds (double)
    public func setProgressDuration(_ duration: TimeInterval) {
        progressDuration = duration
    }
    
    ///Set color of progress
    ///
    ///- Parameters:
    /// - color - new progress color (UIColor)
    public func setProgressColor(_ color: UIColor) {
        progressColor = color
    }
    
    public func setFullScreen(_ need: Bool) {
        needFullScreen = need
    }
    
    public func setTitleEnabled(_ enabled: Bool) {
        needShowTitle = enabled
    }
}

//MARK: - Network for App
extension StorySDK {
    public func getApps(completion: @escaping (Error?, StoryApp?) -> Void) {
        NetworkManager.shared.getApps(StorySDK.sdk_id, completion: { error, result in
            if let error = error {
                completion(error, nil)
                return
            }
            if let result = result, let app = result.first {
                completion(nil, app)
            }
            else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]), nil)
            }
        })
    }
    
    public func getApp(appID: String, completion: @escaping (Error?, StoryApp?) -> Void) {
        NetworkManager.shared.getApp(StorySDK.sdk_id, appID: appID, completion: { error, result in
            if let error = error {
                completion(error, nil)
                return
            }
            if let result = result {
                completion(nil, result)
            }
            else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]), nil)
            }
        })
    }
}

//MARK: - Network for Groups
extension StorySDK {
    public func getGroups(statistic: Bool? = nil, date_from: String? = nil, date_to: String? = nil, completion: @escaping (Error?, [StoryGroup]?) -> Void) {
        NetworkManager.shared.getApps(StorySDK.sdk_id, completion: { error, result in
            if let error = error {
                completion(error, nil)
                return
            }
            if let result = result {
                let appID = result[0].id
                self.getGroups(appID: appID, statistic: statistic, date_from: date_from, date_to: date_to, completion: { err, groups in
                    completion(err, groups)
                })
            }
            else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]), nil)
            }
        })
    }
    
    public func getGroups(appID: String, statistic: Bool? = nil, date_from: String? = nil, date_to: String? = nil, completion: @escaping (Error?, [StoryGroup]?) -> Void) {
        NetworkManager.shared.getGroups(StorySDK.sdk_id, appID: appID, statistic: statistic, date_from: date_from, date_to: date_to, completion: { error, result in
            if let error = error {
                completion(error, nil)
                return
            }
            if let result = result {
                completion(nil, result)
            }
            else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]), nil)
            }
        })
    }
    
    public func getGroup(appID: String, groupID: String, statistic: Bool? = nil, date_from: String? = nil, date_to: String? = nil, completion: @escaping (Error?, StoryGroup?) -> Void) {
        NetworkManager.shared.getGroup(StorySDK.sdk_id, appID: appID, groupID: groupID, statistic: statistic, date_from: date_from, date_to: date_to, completion: { error, result in
            if let error = error {
                completion(error, nil)
                return
            }
            if let result = result {
                completion(nil, result)
            }
            else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]), nil)
            }
        })
    }
}

//MARK: - Network for Stories
extension StorySDK {
    public func getStories(_ group: StoryGroup, statistic: Bool? = nil, completion: @escaping (Error?, [Story]?) -> Void) {
        self.getStories(appID: group.app_id, groupID: group.id, statistic: statistic, completion: completion)
    }
    
    public func getStories(appID: String, groupID: String, statistic: Bool? = nil, completion: @escaping (Error?, [Story]?) -> Void) {
        NetworkManager.shared.getStories(StorySDK.sdk_id, appID: appID, groupID: groupID, statistic: statistic, completion: { error, result in
            if let error = error {
                completion(error, nil)
                return
            }
            if let result = result {
//                if activeOnly {
//                    let filtered = result.filter({ $0.status == "active" })
//                    completion(nil, filtered)
//                }
//                else {
                    completion(nil, result)
//                }
            }
            else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]), nil)
            }
        })
    }
}

//MARK: - Statistic
extension StorySDK {
    static func sendStatistic(_ reaction: Data, completion: @escaping (Error?, [String: Any]?, Int) -> Void) {
        NetworkManager.shared.sendStatistic(sdk_id, reaction: reaction, completion: { error, dict, status in
            completion(error, dict, status)
        })
    }
}
