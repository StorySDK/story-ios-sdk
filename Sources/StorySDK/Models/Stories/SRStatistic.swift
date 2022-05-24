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
    ///  When user looks on story more then 2 seconds
    case impression
    /// Talk about message
    case answer
    /// When user slides story back
    case next
    /// When user opens group
    case back
    /// When user slides story forward
    case open
    /// When user closes group
    case close
}
