//
//  SRStatistic.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 03.02.2022.
//

import Foundation

public struct SRStatistic: Encodable {
    public var type: SRStatisticAction
    public var storyId: String?
    public var widgetId: String?
    public var userId: String?
    public var groupId: String?
    public var value: String?
    public var locale: String?
}

public enum SRStatisticAction: String, Encodable {
    /// Click on widget
    case click
    /// Time of displaying of a story
    case duration
    /// When a user looks on story more then 2 seconds
    case impression
    /// Talk about message
    case answer
    /// When a user slides a story forward
    case next
    /// When a user slides a story backward
    case back
    /// When a user opens  a group
    case open
    /// When a user closes a group
    case close
}
