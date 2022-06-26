//
//  SRRectangleView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

class SRRectangleView: SRImageWidgetView {
    let rectangleWidget: SRRectangleWidget
    
    init(story: SRStory, data: SRWidget, rectangleWidget: SRRectangleWidget, imageUrl: URL?, loader: SRImageLoader, logger: SRLogger) {
        self.rectangleWidget = rectangleWidget
        super.init(story: story, data: data, url: imageUrl, loader: loader, logger: logger)
    }
    
    override func setupView() {
        super.setupView()
        if case .color(let color) = rectangleWidget.fillColor {
            let fillOpacity = CGFloat(rectangleWidget.fillOpacity / 100)
            contentView.backgroundColor = color.withAlphaComponent(fillOpacity)
        }
        
        contentView.layer.cornerRadius = CGFloat(rectangleWidget.fillBorderRadius) * bounds.height / data.position.realHeight

        if rectangleWidget.hasBorder, case .color(let color) = rectangleWidget.strokeColor {
            let strokeOpacity = CGFloat(rectangleWidget.strokeOpacity / 100)
            contentView.layer.borderColor = color.withAlphaComponent(strokeOpacity).cgColor
            contentView.layer.borderWidth = CGFloat(rectangleWidget.strokeThickness)
        }
        isUserInteractionEnabled = false
    }
}
