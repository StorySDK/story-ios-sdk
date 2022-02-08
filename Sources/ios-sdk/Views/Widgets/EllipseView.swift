//
//  EllipseView.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

class EllipseView: UIView {
    private var data: WidgetData!
    private var ellipseWidget: EllipseWidget!

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(frame: CGRect, data: WidgetData, ellipseWidget: EllipseWidget) {
        self.init(frame: frame)
        self.data = data
        self.ellipseWidget = ellipseWidget
        self.transform = CGAffineTransform.identity.rotated(by: data.position.rotate * .pi / 180)
        prepareUI()
    }
    
    private func prepareUI() {
        backgroundColor = .clear//.withAlphaComponent(ellipseWidget.widgetOpacity / 100)
        layer.shadowColor = black.withAlphaComponent(0.15).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4

        switch ellipseWidget.fillColor {
        case .color(let value):
            backgroundColor = Utils.getColor(value.value).withAlphaComponent(CGFloat(ellipseWidget.fillOpacity / 100))
        default:
            break
        }
        layer.cornerRadius = frame.height / 2

        if ellipseWidget.hasBorder {
            switch ellipseWidget.strokeColor {
            case .color(let value):
                let borderColor = Utils.getColor(value.value).withAlphaComponent(CGFloat(ellipseWidget.strokeOpacity / 100))
                layer.borderColor = borderColor.cgColor
            default:
                break
            }
            
            layer.borderWidth = CGFloat(ellipseWidget.strokeThickness)
        }
    }
}
