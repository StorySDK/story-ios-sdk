//
//  SRStoryData.swift
//  
//
//  Created by Aleksei Cherepanov on 23.05.2022.
//

import Foundation

public struct SRStoryData: Decodable {
    public var background: SRColor?
    public var status: String // enum?
    public var widgets: [SRWidget]
}
