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
    let widgets: [WidgetData]
    let background: BackgroundType
    let status: String
    
    public init() {
        widgets = [WidgetData]()
        background = BackgroundType.null("null")
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
        
        if let backgroundDict = dict["background"] as? Json {
            let type = backgroundDict["type"] as! String
            if type == "color" || type == "image" || type == "video"{
                self.background = BackgroundType.color(ColorValue(from: backgroundDict))
            } else if type == "gradient" {
                self.background = BackgroundType.gradient(GradientValue(from: backgroundDict))
            } else {
                self.background = BackgroundType.null("null")
            }
        } else {
            self.background = BackgroundType.null("null")
        }
        
        self.status = dict["status"] as? String ?? "draft"
    }
}
