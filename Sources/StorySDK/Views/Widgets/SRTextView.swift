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
        let lbl = UILabel()
        lbl.numberOfLines = 0
        
        return lbl
    }()
    
    init(story: SRStory, data: SRWidget, textWidget: SRTextWidget, imageUrl: URL?, loader: SRImageLoader, logger: SRLogger) {
        self.textWidget = textWidget
        super.init(story: story, data: data, url: imageUrl, loader: loader, logger: logger)
    }
    
    override func setupView() {
        super.setupView()
        isUserInteractionEnabled = false
        [label].forEach(contentView.addSubview)
        
        let textColor: UIColor
        switch textWidget.color {
        case .color(let color, _):
            textColor = color
        default:
            textColor = SRThemeColor.black.color
        }
        
        let alignment: NSTextAlignment
        switch textWidget.align {
        case "left":
            alignment = .left
        case "center":
            alignment = .center
        case "right":
            alignment = .right
        default:
            alignment = .center
        }
        
        label.textColor = textColor
        label.textAlignment = alignment
        label.font = UIFont.improvedFont(family: textWidget.fontFamily,
                                 ofSize: textWidget.fontSize, weight: UIFont.Weight(textWidget.fontParams.weight))
        label.text = textWidget.text
        
        #if DEBUG
        label.backgroundColor = .systemGreen
        contentView.backgroundColor = .systemOrange
        #endif
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 0, y: 0, width: data.position.realWidth / UIScreen.main.scale, height: data.position.realHeight / UIScreen.main.scale)
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
