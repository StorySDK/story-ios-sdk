//
//  SRUserDefaults.swift
//  
//
//  Created by Aleksei Cherepanov on 22.05.2022.
//

import Foundation

public protocol SRUserDefaults: AnyObject {
    
    // MARK: - Getting Values
    
    func isPresented(group: String) -> Bool
    
    // MARK: - Setting Values
    
    func didPresent(group: String)
    
    // MARK: - Removing Values
    
    func clean()
    func removePresented(group: String)
}

struct SRUserDefaultsModel: Codable {
    var presentedStories: Set<String> = .init()
}
