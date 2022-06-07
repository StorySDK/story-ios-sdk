//
//  RectangleView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

class RectangleView: SRWidgetView {
    let rectangleWidget: SRRectangleWidget
    
    init(data: SRWidget, rectangleWidget: SRRectangleWidget) {
        self.rectangleWidget = rectangleWidget
        super.init(data: data)
    }
    
    override func setupView() {
        super.setupView()
        if case .color(let color) = rectangleWidget.fillColor {
            let fillOpacity = CGFloat(rectangleWidget.fillOpacity / 100)
            contentView.backgroundColor = color.withAlphaComponent(fillOpacity)
        }
        contentView.layer.cornerRadius = CGFloat(rectangleWidget.fillBorderRadius)

        if rectangleWidget.hasBorder, case .color(let color) = rectangleWidget.strokeColor {
            let strokeOpacity = CGFloat(rectangleWidget.strokeOpacity / 100)
            contentView.layer.borderColor = color.withAlphaComponent(strokeOpacity).cgColor
            contentView.layer.borderWidth = CGFloat(rectangleWidget.strokeThickness)
        }
    }
}
