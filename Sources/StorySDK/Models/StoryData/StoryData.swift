//
//  StoryData.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

import UIKit

/// Set of story data
///
/// Params:
/// - widgest - array of WidgetData
/// - background - background (solid color or gradient color)
/// - status - draft or active
public struct StoryData {
    var widgets: [WidgetData]
    var background: SRColor?
    var status: String
    
    public init() {
        widgets = [WidgetData]()
        status = "draft"
    }
    
    public init(from dict: Json) {
        var widgets = [WidgetData]()
        let array = dict["widgets"] as! NSArray
        for widgetDict in array {
            let widget = WidgetData(from: widgetDict as! Json)
            widgets.append(widget)
        }
        self.widgets = widgets
        self.status = dict["status"] as? String ?? "draft"
        (dict["background"] as? Json).map { background = .init(json: $0) }
    }
}
