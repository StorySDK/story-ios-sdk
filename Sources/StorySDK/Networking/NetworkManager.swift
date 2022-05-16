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
    private let configuration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Content-type": "application/json"]
        return config
    }()
    private lazy var session = URLSession(
        configuration: configuration,
        delegate: nil,
        delegateQueue: .main
    )
    private static let baseUrl = "https://api.diffapp.link/sdk/v1/"
    
    func setupAuthorization(_ id: String?) {
        configuration.httpAdditionalHeaders?["Authorization"] = id.map { "SDK \($0)" }
    }
    func setupLanguage(_ value: String?) {
        configuration.httpAdditionalHeaders?["Accept-Language"] = value
    }
}

// MARK: - App
extension NetworkManager {
    /// Fetch story app
    func getApp(completion: @escaping (Result<StoryApp, Error>) -> Void) {
        guard let request = Self.makeRequest("app", method: .get) else {
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
    ///   - from: From date
    ///   - to: To date
    ///   - statistic: Send statistics   
    func getGroups(from: String? = nil, to: String? = nil, statistic: Bool? = nil, completion: @escaping (Result<[StoryGroup], Error>) -> Void) {
        guard let request = Self.makeRequest("groups", method: .get, statistic: statistic) else {
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
    
    /// Fetch group for the app
    /// - Parameters:
    ///   - groupId: Group identifier
    ///   - statistic: Send statistics
    ///   - from: From date
    ///   - to: To date
    func getGroup(groupId: String, statistic: Bool? = nil, from: String? = nil, to: String? = nil, completion: @escaping (Result<StoryGroup, Error>) -> Void) {
        guard let request = Self.makeRequest("groups/\(groupId)", method: .get, statistic: statistic) else {
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
    ///   - groupId: Group identifier
    ///   - statistic: Send statistics
    func getStories(groupId: String, statistic: Bool? = nil, completion: @escaping (Result<[Story], Error>) -> Void) {
        guard let request = Self.makeRequest("groups/\(groupId)/stories", method: .get, statistic: statistic) else {
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
    
    func sendStatistic(reaction: Data, completion: @escaping (Result<Json, Error>) -> Void) {
        guard var request = Self.makeRequest("reactions", method: .post) else {
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
        if let error = error { throw error }
        guard let data = data, let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            throw SRError.emptyResponse
        }
        let object = try JSONDecoder.storySdk.decode(SKResponse<T>.self, from: data)
        guard (200..<300).contains(statusCode) else {
            throw SRError.serverError(object.error)
        }
        guard let result = object.data else {
            throw SRError.emptyResponse
        }
        return result
    }
    
    private static func decodeJsonArray(from data: Data?, response: URLResponse?, error: Error?) throws -> [Json] {
        let data = try decodeData(from: data, response: response, error: error)
        guard let json = data as? [Json] else { throw SRError.emptyResponse }
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
        print(appData)
        return appData
    }
    
    private static func makeRequest(_ path: String, method: HTTPMethod, statistic: Bool? = nil) -> URLRequest? {
        var urlString = "\(baseUrl)\(path)"
        statistic.map { urlString += "?statistic=\($0)" }
        guard let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }
    
    private enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
}

private extension JSONDecoder {
    static let storySdk: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(.rfc3339) // .iso8601
        return decoder
    }()
}

struct SKResponse<T: Decodable>: Decodable {
    var data: T?
    var error: String?
}

private extension DateFormatter {
    static let rfc3339: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }
}
