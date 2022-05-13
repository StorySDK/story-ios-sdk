//
//  Story.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 09.04.2022.
//

import Foundation
import Foundation

public struct Story {
    var id: String = ""
    var groupId: String = ""
    var position: Int = 0
    var storyData: [String: StoryData] = [:]
    var statistic: StoreStatistic? = nil

    public init() {}
    
    public init(from dict: Json) {
        self.id = dict["id"] as? String ?? ""
        self.groupId = dict["group_id"] as? String ?? ""
        self.position = dict["position"] as? Int ?? 0
        
        if let story_dict = dict["story_data"] as? [String: Json] {
            var stories = [String: StoryData]()
            for key in story_dict.keys {
                if let json = story_dict[key] {
                    let story = StoryData(from: json)
                    stories.updateValue(story, forKey: key)
                }
            }
            self.storyData = stories
        } else {
            self.storyData = [:]
        }
        
        if let statisticDict = dict["statistic"] as? Json {
            self.statistic = StoreStatistic(from: statisticDict)
        } else {
            self.statistic = nil
        }
    }
    
    public func getStoryData(locale: String, defaultLocale: String? = nil) -> StoryData? {
        if let data = storyData[locale] { return data }
        guard let defaultLocale = defaultLocale else { return nil }
        return storyData[defaultLocale]
    }
}
