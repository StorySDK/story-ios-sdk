//
//  WidgetReaction.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 22.02.2022.
//

import Foundation

struct WidgetReaction: Codable {
    let data: [String]
    let story_id: String
    let group_id: String
    let user_id: String
    let widget_id: String?
    let type: String
    let value: [String]
    let locale: String

    init?(storyId: String?, groupId: String?, userId: String?, widgetId: String? = nil, type: String? = nil, value: String? = nil, locale: String) {
        guard let storyId = storyId else { return nil }
        guard let groupId = groupId else { return nil }
        guard let userId = userId else { return nil }
        guard let type = type else { return nil }
        guard let value = value else { return nil }
        
        self.data = [String]()
        self.story_id = storyId
        self.group_id = groupId
        self.user_id = userId
        self.widget_id = widgetId
        self.type = type
        self.value = [value]
        self.locale = locale
    }
}
