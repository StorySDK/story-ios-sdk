//
//  EllipseView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

class EllipseView: SRImageWidgetView {
    let ellipseWidget: SREllipseWidget

    init(story: SRStory, data: SRWidget, ellipseWidget: SREllipseWidget, imageUrl: URL?, loader: SRImageLoader, logger: SRLogger) {
        self.ellipseWidget = ellipseWidget
        super.init(story: story, data: data, url: imageUrl, loader: loader, logger: logger)
    }
    
    override func setupView() {
        super.setupView()
        guard url == nil else { return }
        if case .color(let color) = ellipseWidget.fillColor {
            let fillOpacity = CGFloat(ellipseWidget.fillOpacity / 100)
            contentView.backgroundColor = color
                .withAlphaComponent(fillOpacity)
        }
        if ellipseWidget.hasBorder, case .color(let color) = ellipseWidget.strokeColor {
            let strokeOpacity = CGFloat(ellipseWidget.strokeOpacity / 100)
            contentView.layer.borderColor = color
                .withAlphaComponent(strokeOpacity)
                .cgColor
            contentView.layer.borderWidth = CGFloat(ellipseWidget.strokeThickness)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        contentView.layer.cornerRadius = frame.height / 2
        CATransaction.commit()
    }
}
