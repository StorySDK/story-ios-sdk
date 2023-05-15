//
//  SRTextView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

class SRTextView: SRImageWidgetView {
    private let textWidget: SRTextWidget
    
    private lazy var label: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    init(story: SRStory, data: SRWidget, textWidget: SRTextWidget, imageUrl: URL?, loader: SRImageLoader, logger: SRLogger) {
        self.textWidget = textWidget
        super.init(story: story, data: data, url: imageUrl, loader: loader, logger: logger)
    }
    
    override func setupView() {
        super.setupView()
        isUserInteractionEnabled = false
        [label].forEach(contentView.addSubview)
        
        switch textWidget.color {
        case .color(let color, _):
            label.textColor = color
        default:
            label.textColor = SRThemeColor.black.color
        }
        
        label.textAlignment = .center
        label.font = .regular(ofSize: min(textWidget.fontSize, 36.0))
        label.text = textWidget.text
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 100)
    }
    
    override func setupContentLayer(_ layer: CALayer) {
        layer.masksToBounds = true
        layer.cornerRadius = 8 * widgetScale
        layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4
    }
}
