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
            
            return lbl
        }()
        
        init(story: SRStory, defaultStorySize: CGSize, data: SRWidget, textWidget: SRTextWidget, imageUrl: URL?, loader: SRImageLoader, logger: SRLogger) {
            self.textWidget = textWidget
            super.init(story: story, defaultStorySize: defaultStorySize, data: data, url: imageUrl, loader: loader, logger: logger)
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
            label.text = textWidget.text
            label.font = StoryFont.improvedFont(family: textWidget.fontFamily,
                                             ofSize: fontSize, weight: textWidget.fontParams.weight)
            delegate?.didWidgetLoad(self)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let boundingRect: CGRect
            if data.positionLimits.isResizableX {
                let inset = data.positionByResolutions.res360x780?.x ?? 0
                boundingRect = textWidget.text.boundingRect(with: CGSize(width: UIScreen.screenBounds.width - 2 * inset, height: 1000), options: .usesLineFragmentOrigin, attributes: [.font: label.font], context: nil)
            } else {
                boundingRect = textWidget.text.boundingRect(with: CGSize(width: bounds.width, height: 1000), options: .usesLineFragmentOrigin, attributes: [.font: label.font], context: nil)
            }
            
            label.frame = CGRect(origin: CGPoint(x: bounds.origin.x, y: bounds.origin.y),
                                 size: CGSize(width: max(bounds.width, boundingRect.width),
                                                                     height: max(bounds.height, boundingRect.height)))
        }
    }
#endif
