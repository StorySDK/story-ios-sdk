//
//  NetworkManager.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 03.02.2022.
//

import AVFoundation
import UIKit

final class NetworkManager {
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
    
    private var baseUrl: String
    
    init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    
    func setupAuthorization(_ id: String?) {
        configuration.httpAdditionalHeaders?["Authorization"] = id.map { "SDK \($0)" }
        updateSession()
    }
    
    func setupLanguage(_ value: String?) {
        configuration.httpAdditionalHeaders?["Accept-Language"] = value
        updateSession()
    }
    
    func setupBaseUrl(_ value: String) {
        guard value != self.baseUrl else { return }
        
        self.baseUrl = value
        updateSession()
    }
    
    private func updateSession() {
        session = URLSession(
            configuration: configuration,
            delegate: nil,
            delegateQueue: .main
        )
    }
}

// MARK: - App
extension NetworkManager {
    /// Fetch story app
    func getApp(completion: @escaping (Result<SRStoryApp, Error>) -> Void) {
        guard let request = makeRequest("app", method: .get) else {
            completion(.failure(SRError.unknownError))
            return
        }
        session.dataTask(with: request) { (data, response, error) in
            do {
                let result = try Self.decode(SRStoryApp.self, from: data, response: response, error: error)
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
    func getGroups(from: String? = nil, to: String? = nil, completion: @escaping (Result<[SRStoryGroup], Error>) -> Void) {
        guard let request = makeRequest("groups", method: .get) else {
            completion(.failure(SRError.unknownError))
            return
        }
        session.dataTask(with: request) { (data, response, error) in
            do {
                let result = try Self.decode([SRStoryGroup].self, from: data, response: response, error: error)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Fetch group for the app
    /// - Parameters:
    ///   - groupId: Group identifier
    ///   - from: From date
    ///   - to: To date
    func getGroup(groupId: String, from: String? = nil, to: String? = nil, completion: @escaping (Result<SRStoryGroup, Error>) -> Void) {
        guard let request = makeRequest("groups/\(groupId)", method: .get) else {
            completion(.failure(SRError.unknownError))
            return
        }
        session.dataTask(with: request) { (data, response, error) in
            do {
                let result = try Self.decode(SRStoryGroup.self, from: data, response: response, error: error)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Fetch stories of the group for the app
    /// - Parameters:
    ///   - groupId: Group identifier
    func getStories(groupId: String, completion: @escaping (Result<[SRStory], Error>) -> Void) {
        guard let request = makeRequest("groups/\(groupId)/stories", method: .get) else {
            completion(.failure(SRError.unknownError))
            return
        }
        session.dataTask(with: request) { (data, response, error) in
            do {
                let stories = try Self.decode([SRStory].self, from: data, response: response, error: error)
                let activeStories = stories.filter { $0.readyToShow() }
                completion(.success(activeStories))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func sendStatistic(reaction: SRStatistic, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard var request = makeRequest("reactions", method: .post) else {
            completion(.failure(SRError.unknownError))
            return
        }
        do {
            request.httpBody = try JSONEncoder.storySdk.encode(reaction)
        } catch {
            completion(.failure(error))
            return
        }
        session.dataTask(with: request) { (_, _, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }.resume()
    }
    
    private static func decode<T>(_ type: T.Type, from data: Data?, response: URLResponse?, error: Error?) throws -> T where T: Decodable {
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
    
    private func makeRequest(_ path: String, method: HTTPMethod) -> URLRequest? {
        guard let url = URL(string: "\(baseUrl)\(path)") else { return nil }
        
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

private extension JSONEncoder {
    static let storySdk: JSONEncoder = {
        let decoder = JSONEncoder()
        decoder.keyEncodingStrategy = .convertToSnakeCase
        decoder.dateEncodingStrategy = .formatted(.rfc3339) // .iso8601
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
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
