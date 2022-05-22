//
//  SRMemoryUserDefaults.swift
//  
//
//  Created by Aleksei Cherepanov on 22.05.2022.
//

import Foundation

public class SRMemoryUserDefaults: SRUserDefaults {
    var model = SRUserDefaultsModel()
    
    public func isPresented(group: String) -> Bool {
        model.presentedStories.contains(group)
    }
    
    public func didPresent(group: String) {
        model.presentedStories.insert(group)
    }
    
    public func clean() {
        model = .init()
    }
    
    public func removePresented(group: String) {
        model.presentedStories.remove(group)
    }
}
