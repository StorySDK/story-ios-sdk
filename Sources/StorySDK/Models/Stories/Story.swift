//
//  Story.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 09.04.2022.
//

import Foundation
import Foundation

public struct Story {
    public var id: String = ""
    public var groupId: String = ""
    public var position: Int = 0
    public var storyData: StoryData?
    public var statistic: StoreStatistic?
    
    public init(from dict: Json) {
        self.id = dict["id"] as? String ?? ""
        self.groupId = dict["group_id"] as? String ?? ""
        self.position = dict["position"] as? Int ?? 0
        (dict["story_data"] as? Json).map { self.storyData = .init(from: $0) }
        if let statisticDict = dict["statistic"] as? Json {
            self.statistic = StoreStatistic(from: statisticDict)
        } else {
            self.statistic = nil
        }
    }
}
