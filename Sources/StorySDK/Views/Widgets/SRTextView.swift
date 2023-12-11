//
//  SRTextView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

#if os(macOS)
    import Cocoa

    class SRTextView: SRImageWidgetView {
        private let textWidget: SRTextWidget
        
        init(story: SRStory, data: SRWidget, textWidget: SRTextWidget, imageUrl: URL?, loader: SRImageLoader, logger: SRLogger) {
            self.textWidget = textWidget
            super.init(story: story, data: data, url: imageUrl, loader: loader, logger: logger)
        }
    }
#elseif os(iOS)
    import UIKit

    class SRTextView: SRImageWidgetView {
        private let textWidget: SRTextWidget
        
        private lazy var label: UILabel = {
            let lbl = UILabel()
            lbl.numberOfLines = 0
//            lbl.layer.borderWidth = 1.0
//            lbl.layer.borderColor = UIColor.green.cgColor
            
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
            
            var fontSize = textWidget.fontSize
            if data.positionLimits.isResizableX {
                let defaultStorySize = CGSize.defaultOnboardingSize()
                let xCoeff = StoryScreen.screenBounds.width / defaultStorySize.width
                
                fontSize = round(textWidget.fontSize * xCoeff)
            }
            
            label.font = UIFont.improvedFont(family: textWidget.fontFamily,
                                             ofSize: fontSize, weight: textWidget.fontParams.weight)
            label.text = textWidget.text
            
            delegate?.didWidgetLoad(self)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            label.frame = bounds
        }
        
        override func setupContentLayer(_ layer: CALayer) {
            layer.masksToBounds = true
        }
    }
#endif
