//
//  StoryGroup.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 03.02.2022.
//

import Foundation

public struct StoryGroup: Codable {
    public var id: String
    public var appId: String
    public var userId: String
    public var title: String
    public var imageUrl: URL?
    public var startTime: String
    public var endTime: String
    public var active: Bool
    public var createdAt: Date
    public var updatedAt: Date
}
