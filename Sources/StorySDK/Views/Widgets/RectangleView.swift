//
//  RectangleView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

class RectangleView: UIView {
    private var data: WidgetData!
    private var rectangleWidget: RectangleWidget!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(frame: CGRect, data: WidgetData, rectangleWidget: RectangleWidget) {
        self.init(frame: frame)
        self.data = data
        self.rectangleWidget = rectangleWidget
        self.transform = CGAffineTransform.identity.rotated(by: data.position.rotate * .pi / 180)
        prepareUI()
    }
    
    private func prepareUI() {
        backgroundColor = .clear// .withAlphaComponent(CGFloat(rectangleWidget.widgetOpacity / 100))
        layer.shadowColor = black.withAlphaComponent(0.15).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4

        if case .color(let color) = rectangleWidget.fillColor {
            backgroundColor = color.withAlphaComponent(CGFloat(rectangleWidget.fillOpacity / 100))
        }
        layer.cornerRadius = CGFloat(rectangleWidget.fillBorderRadius)

        if rectangleWidget.hasBorder, case .color(let color) = rectangleWidget.strokeColor {
            layer.borderColor = color.withAlphaComponent(CGFloat(rectangleWidget.strokeOpacity / 100)).cgColor
            layer.borderWidth = CGFloat(rectangleWidget.strokeThickness)
        }
    }
}
