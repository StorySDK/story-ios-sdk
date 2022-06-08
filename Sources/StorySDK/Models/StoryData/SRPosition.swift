//
//  SRPosition.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

import Foundation

public struct SRPosition: Decodable {
    public var x: Double
    public var y: Double
    public var realWidth: Double
    public var realHeight: Double
    public var rotate: Double
    public var center: SRPoint?
}

public struct SRPoint: Decodable {
    public var x: Double
    public var y: Double
}
