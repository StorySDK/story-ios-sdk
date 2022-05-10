//
//  StoreStatistic.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 03.02.2022.
//

import Foundation

public struct StoreGroupStatistic: Codable {
    public let open: Int
    public let impression: Int
    public let duration: Double
    public let click: Int
    
    public init() {
        self.open = 0
        self.impression = 0
        self.duration = 0
        self.click = 0
    }
    
    public init(from dict: Json) {
        self.open = dict["open"] as? Int ?? 0
        self.impression = dict["impression"] as? Int ?? 0
        self.duration = dict["duration"] as? Double ?? 0
        self.click = dict["click"] as? Int ?? 0
    }
}

public struct StoreStatistic: Codable {
    public let next: Int
    public let back: Double
    public let duration: Int
    public let views: Int
    public let close: Int
    public let actions: Int
    
    public init() {
        self.next = 0
        self.back = 0
        self.duration = 0
        self.views = 0
        self.close = 0
        self.actions = 0
    }
    
    public init(from dict: Json) {
        self.next = dict["next"] as? Int ?? 0
        self.back = dict["back"] as? Double ?? 0
        self.duration = dict["duration"] as? Int ?? 0
        self.views = dict["views"] as? Int ?? 0
        self.close = dict["close"] as? Int ?? 0
        self.actions = dict["actions"] as? Int ?? 0
    }
}
