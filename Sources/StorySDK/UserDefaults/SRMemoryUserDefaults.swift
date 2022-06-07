//
//  SRMemoryUserDefaults.swift
//  
//
//  Created by Aleksei Cherepanov on 22.05.2022.
//

import Foundation

public class SRMemoryUserDefaults: SRUserDefaults {
    var model = SRUserDefaultsModel()
    
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
}
