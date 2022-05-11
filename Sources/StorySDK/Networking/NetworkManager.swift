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
    private let session = URLSession.shared
    private static let baseUrl = "https://api.diffapp.link/api/v1/"
}

// MARK: - App
extension NetworkManager {
    /// Method for getting Story Apps with specific SDK ID
    /// - Parameters:
    ///   - sdkId: The corresponding SDK ID for the App
    func getApps(_ sdkId: String, completion: @escaping (Result<[StoryApp], Error>) -> Void) {
        guard let request = Self.makeRequest("apps", method: .get, sdkId: sdkId) else {
            completion(.failure(SRError.unknownError))
            return
        }
        session.dataTask(with: request) { (data, response, error) in
            do {
                let result = try Self.decode([StoryApp].self, from: data, response: response, error: error)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Fetch the app with id
    /// - Parameters:
    ///   - sdkId: SDK Token
    ///   - appId: App identifier
    func getApp(_ sdkId: String, appId: String, completion: @escaping (Result<StoryApp, Error>) -> Void) {
        guard let request = Self.makeRequest("apps/\(appId)", method: .get, sdkId: sdkId) else {
            completion(.failure(SRError.unknownError))
            return
        }
        session.dataTask(with: request) { (data, response, error) in
            do {
                let result = try Self.decode(StoryApp.self, from: data, response: response, error: error)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Fetch groups for the app
    /// - Parameters:
    ///   - sdkId: SDK Token
    ///   - appId: App identifier
    ///   - statistic: Send statistics
    ///   - from: From date
    ///   - to: To date
    func getGroups(_ sdkId: String, appId: String, statistic: Bool? = nil, from: String? = nil, to: String? = nil, completion: @escaping (Result<[StoryGroup], Error>) -> Void) {
        guard let request = Self.makeRequest("apps/\(appId)/groups", method: .get, sdkId: sdkId, statistic: statistic) else {
            completion(.failure(SRError.unknownError))
            return
        }
        session.dataTask(with: request) { (data, response, error) in
            do {
                let result = try Self.decode([StoryGroup].self, from: data, response: response, error: error)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    /**
     Получение группы с group_id для  приложения с конкретным app_id, привязанное к SDK token
     */
    
    /// Fetch group for the app
    /// - Parameters:
    ///   - sdkId: SDK Token
    ///   - appId: App identifier
    ///   - groupId: Group identifier
    ///   - statistic: Send statistics
    ///   - from: From date
    ///   - to: To date
    func getGroup(_ sdkId: String, appId: String, groupId: String, statistic: Bool? = nil, from: String? = nil, to: String? = nil, completion: @escaping (Result<StoryGroup, Error>) -> Void) {
        guard let request = Self.makeRequest("apps/\(appId)/groups/\(groupId)", method: .get, sdkId: sdkId, statistic: statistic) else {
            completion(.failure(SRError.unknownError))
            return
        }
        session.dataTask(with: request) { (data, response, error) in
            do {
                let result = try Self.decode(StoryGroup.self, from: data, response: response, error: error)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Fetch stories of the group for the app
    /// - Parameters:
    ///   - sdkId: SDK Token
    ///   - appId: App identifier
    ///   - groupId: Group identifier
    ///   - statistic: Send statistics
    func getStories(_ sdkId: String, appId: String, groupId: String, statistic: Bool? = nil, completion: @escaping (Result<[Story], Error>) -> Void) {
        guard let request = Self.makeRequest("apps/\(appId)/groups/\(groupId)/stories", method: .get, sdkId: sdkId, statistic: statistic) else {
            completion(.failure(SRError.unknownError))
            return
        }
        session.dataTask(with: request) { (data, response, error) in
            do {
                let storiesData = try Self.decodeJsonArray(from: data, response: response, error: error)
                let result = storiesData.map { Story(from: $0) }
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func sendStatistic(_ sdkId: String, reaction: Data, completion: @escaping (Result<Json, Error>) -> Void) {
        guard var request = Self.makeRequest("reactions", method: .post, sdkId: sdkId) else {
            completion(.failure(SRError.unknownError))
            return
        }
        request.httpBody = reaction
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            do {
                if let json = try Self.decodeData(from: data, response: response, error: error) as? Json {
                    completion(.success(json))
                } else {
                    throw SRError.emptyResponse
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private static func decode<T>(_ type: T.Type, from data: Data?, response: URLResponse?, error: Error?) throws -> T where T : Decodable {
        let data = try decodeData(from: data, response: response, error: error)
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        return try JSONDecoder().decode(type, from: jsonData)
    }
    
    private static func decodeJsonArray(from data: Data?, response: URLResponse?, error: Error?) throws -> [Json] {
        let data = try decodeData(from: data, response: response, error: error)
        guard let json = data as? [Json] else {
            throw SRError.emptyResponse
        }
        return json
    }
    
    private static func decodeData(from data: Data?, response: URLResponse?, error: Error?) throws -> Any {
        if let error = error { throw error }
        guard let data = data, let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            throw SRError.emptyResponse
        }
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        guard let json = jsonObject as? Json else {
            throw SRError.wrongFormat
        }
        guard statusCode == 200 else {
            throw SRError.serverError(json["error"] as? String)
        }
        guard let appData = json["data"] else {
            throw SRError.emptyResponse
        }
        return appData
    }
    
    private static func makeRequest(_ path: String, method: HTTPMethod, sdkId: String, statistic: Bool? = nil) -> URLRequest? {
        var urlString = "\(baseUrl)\(path)"
        statistic.map { urlString += "?statistic=\($0)" }
        guard let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue("SDK \(sdkId)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
}
