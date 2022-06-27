//
//  SRMemoryUserDefaults.swift
//  
//
//  Created by Aleksei Cherepanov on 22.05.2022.
//

import Foundation
import Combine

public class SRMemoryUserDefaults: SRUserDefaults {
    @Published var model = SRUserDefaultsModel()
    
    public var userId: String {
        get {
            if let userId = model.userId { return userId }
            let userId = UUID().uuidString
            self.userId = userId
            return userId
        }
        set { model.userId = newValue }
    }
    
    public func isPresented(group: String) -> Bool {
        model.presentedStories.contains(group)
    }
    
    public func reaction(widgetId: String) -> String? {
        model.widgetReactions[widgetId]
    }
    
    public func didPresent(group: String) {
        model.presentedStories.insert(group)
    }
    
    public func setReaction(widgetId: String, value: String?) {
        model.widgetReactions[widgetId] = value
    }
    
    public func clean() {
        model = .init()
    }
    
    public func removePresented(group: String) {
        model.presentedStories.remove(group)
    }
    
    public func presentedStoriesObserve(for groups: Set<String>) -> AnyPublisher<[String : Bool], Never> {
        $model
            .map(\.presentedStories)
            .removeDuplicates()
            .map { presented -> [String: Bool] in
                groups.reduce([String: Bool]()) { partialResult, group in
                    var result = partialResult
                    result[group] = presented.contains(group)
                    return result
                }
            }
            .eraseToAnyPublisher()
    }
}
