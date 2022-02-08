//
//  WidgetData.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

import UIKit

///Set of widget's data
///
///Params:
///- id - widget id
///- position - widget position
///- positionLimits - limits of position (in iOS case useless)
///- content - widget description content
public struct WidgetData {
    public let id: String
    public let position: WidgetPosition
    public let positionLimits: WidgetPositionLimits
    public let content: WidgetContent
    
    public init() {
        self.id = ""
        self.content = WidgetContent()
        self.position = WidgetPosition()
        self.positionLimits = WidgetPositionLimits()
    }
    
    public init(from dict: Json) {
        self.id = dict["id"] as? String ?? ""
        
        if let pos = dict["position"] as? Json {
            self.position = WidgetPosition(from: pos)
        }
        else {
            self.position = WidgetPosition()
        }
        if let posLimit = dict["positionLimits"] as? Json {
            self.positionLimits = WidgetPositionLimits(from: posLimit)
        }
        else {
            self.positionLimits = WidgetPositionLimits()
        }
        if let contentDict = dict["content"] as? Json {
            self.content = WidgetContent(from: contentDict)
        }
        else {
            self.content = WidgetContent()
        }
    }
}
