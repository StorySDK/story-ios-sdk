//
//  Story.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 09.04.2022.
//

import Foundation
import Foundation

public struct Story {
    let id: String
    let group_id: String
    let position: Int
    let story_data: [String: StoryData]
    let statistic: StoreStatistic?

    public init() {
        id = ""
        group_id = ""
        position = 0
        story_data = [String: StoryData]()
        statistic = nil
    }
    
    public init(from dict: Json) {
        self.id = dict["id"] as? String ?? ""
        self.group_id = dict["group_id"] as? String ?? ""
        self.position = dict["position"] as? Int ?? 0
        
        if let story_dict = dict["story_data"] as? [String: Json] {
            var stories = [String: StoryData]()
            for key in story_dict.keys {
                if let json = story_dict[key] {
                    let story = StoryData(from: json)
                    stories.updateValue(story, forKey: key)
                }
            }
            self.story_data = stories
        } else {
            self.story_data = [String: StoryData]()
        }
        
        if let statisticDict = dict["statistic"] as? Json {
            self.statistic = StoreStatistic(from: statisticDict)
        } else {
            self.statistic = nil
        }
    }
    
    public func getStoryData(locale: String) -> StoryData? {
        story_data[locale] ?? story_data["en"]
    }
}
