//
//  SRUserDefaults.swift
//  
//
//  Created by Aleksei Cherepanov on 22.05.2022.
//

import Foundation
import Combine

public protocol SRUserDefaults: AnyObject {
    
    var userId: String { get set }
    
    // MARK: - Getting Values
    
    func isPresented(group: String) -> Bool
    func reaction(widgetId: String) -> String?
    
    // MARK: - Setting Values
    
    func didPresent(group: String)
    func setReaction(widgetId: String, value: String?)
    
    // MARK: - Removing Values
    
    func clean()
    func removePresented(group: String)
    
    // MARK: - Combine
    
    func presentedStoriesObserve(for groups: Set<String>) -> AnyPublisher<[String: Bool], Never>
}

struct SRUserDefaultsModel: Codable {
    var presentedStories: Set<String> = .init()
    var userId: String?
    var widgetReactions: [String: String] = [:]
}
