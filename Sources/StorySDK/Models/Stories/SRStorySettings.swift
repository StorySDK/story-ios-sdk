//
//  SRStorySettings.swift
//  StorySDK
//
//  Created by Igor Efremov on 12.04.2023.
//

import Foundation

public enum SRSizePreset: String {
    case IphoneSmall
    case IphoneLarge
}

public struct SRStorySettings: Decodable {
    public var scoreResultLayersGroupId: String?
    public var scoreType: String?
    public var sizePreset: SRSizePreset?
    public var isProhibitToClose: Bool
    public var isProgressHidden: Bool
    public var addToStories: Bool
    public var storiesSize: String?
    
    enum CodingKeys: String, CodingKey {
        case scoreResultLayersGroupId, scoreType, sizePreset, isProhibitToClose, isProgressHidden, addToStories, storiesSize
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        scoreResultLayersGroupId = try? container.decode(String.self, forKey: .scoreResultLayersGroupId)
        scoreType = try? container.decode(String.self, forKey: .scoreType)
        if let rawSizePreset = try? container.decode(String.self, forKey: .sizePreset) {
            sizePreset = SRSizePreset(rawValue: rawSizePreset)
        }
        isProhibitToClose = try container.decodeIfPresent(Bool.self, forKey: .isProhibitToClose) ?? false
        isProgressHidden = try container.decodeIfPresent(Bool.self, forKey: .isProgressHidden) ?? false
        addToStories = try container.decodeIfPresent(Bool.self, forKey: .addToStories) ?? true
        storiesSize = try? container.decode(String.self, forKey: .storiesSize)
    }
}
