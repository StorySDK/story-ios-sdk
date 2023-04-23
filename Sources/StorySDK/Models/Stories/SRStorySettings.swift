//
//  SRStorySettings.swift
//  StorySDK
//
//  Created by Ingvarr Alef on 12.04.2023.
//

import Foundation

public struct SRStorySettings: Decodable {
    public var scoreResultLayersGroupId: String?
    public var scoreType: String?
    public var isProhibitToClose: Bool
    public var isProgressHidden: Bool
    public var addToStories: Bool
    public var storiesSize: String?
    
    enum CodingKeys: String, CodingKey {
        case scoreResultLayersGroupId, scoreType, isProhibitToClose, isProgressHidden, addToStories, storiesSize
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        scoreResultLayersGroupId = try? container.decode(String.self, forKey: .scoreResultLayersGroupId)
        scoreType = try? container.decode(String.self, forKey: .scoreType)
        isProhibitToClose = try container.decodeIfPresent(Bool.self, forKey: .isProhibitToClose) ?? false
        isProgressHidden = try container.decodeIfPresent(Bool.self, forKey: .isProgressHidden) ?? false
        addToStories = try container.decodeIfPresent(Bool.self, forKey: .addToStories) ?? true
        storiesSize = try? container.decode(String.self, forKey: .storiesSize)
    }
}
