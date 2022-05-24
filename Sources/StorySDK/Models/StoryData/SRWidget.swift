//
//  SRWidget.swift
//  
//
//  Created by Aleksei Cherepanov on 23.05.2022.
//

import Foundation

public struct SRWidget: Decodable {
    public var id: String
    public var position: SRPosition
    public var positionLimits: SRPositionLimits
    public var content: SRWidgetContent
}
