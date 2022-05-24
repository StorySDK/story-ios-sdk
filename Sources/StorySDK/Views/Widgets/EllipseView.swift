//
//  EllipseView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

class EllipseView: SRWidgetView {
    let ellipseWidget: EllipseWidget

    init(data: SRWidget, ellipseWidget: EllipseWidget) {
        self.ellipseWidget = ellipseWidget
        super.init(data: data)
    }
    
    override func setupView() {
        super.setupView()

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
