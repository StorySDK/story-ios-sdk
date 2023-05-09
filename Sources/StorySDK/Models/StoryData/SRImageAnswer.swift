//
//  SRImageAnswer.swift
//  StorySDK
//
//  Created by Ingvarr Alef on 09.05.2023.
//

import Foundation

public struct SRImageAnswer: Decodable {
    public var id: String
    public var title: String
    public var image: SRImageURL?
    
    enum CodingKeys: String, CodingKey {
        case id, title, image
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        image = try container.decode(SRImageURL.self, forKey: .image)
    }
}
