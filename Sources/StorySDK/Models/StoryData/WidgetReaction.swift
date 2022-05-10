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

    init(story_id: String, group_id: String, user_id: String, widget_id: String? = nil, type: String, value: String, locale: String) {
        self.data = [String]()
        self.story_id = story_id
        self.group_id = group_id
        self.user_id = user_id
        self.widget_id = widget_id
        self.type = type
        self.value = [value]
        self.locale = locale
    }
}
