//
//  NetworkManager.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 03.02.2022.
//

import AVFoundation
import UIKit

final class NetworkManager {
    static let shared = NetworkManager()
    private let base_url = "https://api.diffapp.link/api/v1/"
}

// MARK: - App
extension NetworkManager {
    /// Method for getting Story Apps with specific SDK ID
    ///
    /// - Parameters:
    ///   - sdkID: The corresponding SDK ID for the App
    ///   - completion: Closure wit herror if any or the array of StoryApp
    func getApps(_ sdkId: String, completion: @escaping (Error?, [StoryApp]?) -> Void) {
        let url = URL(string: "\(base_url)apps")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue("SDK \(sdkId)", forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(error, nil)
                return
            }
            
            guard let data = data else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Data is empty for apps"]), nil)
                return
            }
            let response = response as? HTTPURLResponse
            print((response)!.statusCode)
            if let json = (try? JSONSerialization.jsonObject(with: data)) as? Json {
                if response?.statusCode == 200 {
                    guard let appData = json["data"] as? NSArray, appData.count > 0, let jsonData = try? JSONSerialization.data(withJSONObject: appData, options: .prettyPrinted), let apps = try? JSONDecoder().decode([StoryApp].self, from: jsonData) else {
                        completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Incorrect data for apps"]), nil)
                        return
                    }
                    completion(nil, apps)
                } else if let errorString = json["error"] as? String {
                    completion(NSError(domain: "", code: response!.statusCode, userInfo: [NSLocalizedDescriptionKey: "\(errorString)\n Code: \(response!.statusCode)"]), nil)
                }
            } else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Data is empty - response code is not equal 200"]), nil)
            }

        }.resume()
    }
    
    /**
     Получение  приложения с конкретным app_id, привязанное к SDK token
     */
    func getApp(_ sdkId: String, appID: String, completion: @escaping (Error?, StoryApp?) -> Void) {
        let url = URL(string: "\(base_url)apps/\(appID)")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue("SDK \(sdkId)", forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(error, nil)
                return
            }
            
            guard let data = data else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Data is empty for apps"]), nil)
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode == 200, let json = (try? JSONSerialization.jsonObject(with: data)) as? Json {
                guard let appData = json["data"] as? Json, let jsonData = try? JSONSerialization.data(withJSONObject: appData, options: .prettyPrinted), let app = try? JSONDecoder().decode(StoryApp.self, from: jsonData) else {
                    completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Incorrect data for apps"]), nil)
                    return
                }

                completion(nil, app)
            } else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Data is empty - response code is not equal 200"]), nil)
            }

        }.resume()
    }
    
    /**
     Получение списка групп приложения с конкретным app_id, привязанное к SDK token
     */
    func getGroups(_ sdkId: String, appID: String, statistic: Bool? = nil, date_from: String? = nil, date_to: String? = nil, completion: @escaping (Error?, [StoryGroup]?) -> Void) {
        var urlString = "\(base_url)apps/\(appID)/groups"
        statistic.map { urlString += "?statistic=\($0)" }
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue("SDK \(sdkId)", forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(error, nil)
                return
            }
            
            guard let data = data else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Data is empty for groups"]), nil)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200, let json = (try? JSONSerialization.jsonObject(with: data)) as? Json {
                    guard let groupsData = json["data"] as? NSArray, let jsonData = try? JSONSerialization.data(withJSONObject: groupsData, options: .prettyPrinted), let groups = try? JSONDecoder().decode([StoryGroup].self, from: jsonData) else {
                        completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Incorrect data for groups"]), nil)
                        return
                    }
                    completion(nil, groups)
                } else {
                    completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Data is empty, responce code = \(response.statusCode)"]), nil)
                }
            } else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Data is empty - response code is not equal 200"]), nil)
            }

        }.resume()
    }
    
    /**
     Получение группы с group_id для  приложения с конкретным app_id, привязанное к SDK token
     */
    func getGroup(_ sdkId: String, appID: String, groupID: String, statistic: Bool? = nil, date_from: String? = nil, date_to: String? = nil, completion: @escaping (Error?, StoryGroup?) -> Void) {
        var urlString = "\(base_url)apps/\(appID)/groups/\(groupID)"
        statistic.map { urlString += "?statistic=\($0)" }
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue("SDK \(sdkId)", forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(error, nil)
                return
            }
            
            guard let data = data else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Data is empty for groups"]), nil)
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode == 200, let json = (try? JSONSerialization.jsonObject(with: data)) as? Json {
                guard let groupData = json["data"] as? Json, let jsonData = try? JSONSerialization.data(withJSONObject: groupData, options: .prettyPrinted), let group = try? JSONDecoder().decode(StoryGroup.self, from: jsonData) else {
                    completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Incorrect data for groups"]), nil)
                    return
                }
                completion(nil, group)
            } else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Data is empty - response code is not equal 200"]), nil)
            }

        }.resume()
    }
    
    /**
     Получение всех Story группы с group_id для  приложения с конкретным app_id, привязанное к SDK token
     */
    func getStories(_ sdkId: String, appID: String, groupID: String, statistic: Bool? = nil, completion: @escaping (Error?, [Story]?) -> Void) {
        var urlString = "\(base_url)apps/\(appID)/groups/\(groupID)/stories"
        statistic.map { urlString += "?statistic=\($0)" }
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue("SDK \(sdkId)", forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(error, nil)
                return
            }
            
            guard let data = data else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Data is empty for groups"]), nil)
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode == 200, let json = (try? JSONSerialization.jsonObject(with: data)) as? Json {
                guard let storiesData = json["data"] as? [Json] else {
                    completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Incorrect data for groups"]), nil)
                    return
                }
                var stories = [Story]()
                for dict in storiesData {
                    let story = Story(from: dict)
                    stories.append(story)
                }
                completion(nil, stories)
            } else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Data is empty - response code is not equal 200"]), nil)
            }

        }.resume()
    }
    
    func sendStatistic(_ sdkId: String, reaction: Data, completion: @escaping (Error?, Json?, Int) -> Void) {
        let url = URL(string: "\(base_url)reactions")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue("SDK \(sdkId)", forHTTPHeaderField: "Authorization")
        request.httpBody = reaction
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(error, nil, 404)
                return
            }
            
            guard let data = data, let json = (try? JSONSerialization.jsonObject(with: data)) as? Json else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Data is empty for statistics"]), nil, 404)
                return
            }
            print(json)

            if let response = response as? HTTPURLResponse {
                completion(nil, json, response.statusCode)
            } else {
                completion(nil, json, 404)
            }

        }.resume()

    }
}
