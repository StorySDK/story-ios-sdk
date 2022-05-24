//
//  StoryGroup.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 03.02.2022.
//

import Foundation

public struct StoryGroup: Codable {
    public let id: String
    public let appId: String
    public let userId: String
    public let title: String
    public let imageUrl: URL?
    public let startTime: String
    public let endTime: String
    public let active: Bool
    public let createdAt: Date
    public let updatedAt: Date
}
