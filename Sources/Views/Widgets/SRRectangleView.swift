//
//  SRRectangleView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

#if os(macOS)
    import Cocoa

    class SRRectangleView: SRImageWidgetView {
        let rectangleWidget: SRRectangleWidget
        
        init(story: SRStory, data: SRWidget, rectangleWidget: SRRectangleWidget, imageUrl: URL?, loader: SRImageLoader, logger: SRLogger) {
            self.rectangleWidget = rectangleWidget
            super.init(story: story, data: data, url: imageUrl, loader: loader, logger: logger)
        }
    }
#elseif os(iOS)
    import UIKit

    class SRRectangleView: SRImageWidgetView {
        let rectangleWidget: SRRectangleWidget
        
        init(story: SRStory, defaultStorySize: CGSize, data: SRWidget, rectangleWidget: SRRectangleWidget, imageUrl: URL?, loader: SRImageLoader, logger: SRLogger) {
            self.rectangleWidget = rectangleWidget
            super.init(story: story, defaultStorySize: defaultStorySize, data: data, url: imageUrl, loader: loader, logger: logger)
        }
        
        override func setupView() {
            super.setupView()
            if case .color(let color, let isFilled) = rectangleWidget.fillColor {
                let fillOpacity = CGFloat(rectangleWidget.fillOpacity / 100)
                contentView.backgroundColor = color.withAlphaComponent(fillOpacity)
            }
            
            if case .gradient(let colors, let isFilled) = rectangleWidget.fillColor {
                let fillOpacity = CGFloat(rectangleWidget.fillOpacity / 100)
            }
            
            contentView.layer.cornerRadius = CGFloat(rectangleWidget.fillBorderRadius) * bounds.height / data.getWidgetPosition(storySize: defaultStorySize).realHeight

            if rectangleWidget.hasBorder, case .color(let color, let isFilled) = rectangleWidget.strokeColor {
                let strokeOpacity = CGFloat(rectangleWidget.strokeOpacity / 100)
                contentView.layer.borderColor = color.withAlphaComponent(strokeOpacity).cgColor
                contentView.layer.borderWidth = CGFloat(rectangleWidget.strokeThickness)
            }
            isUserInteractionEnabled = false
        }
        
        override func layoutSubviews() {
             super.layoutSubviews()
            
            if case .gradient(let colors, let isFilled) = rectangleWidget.fillColor {
                var alpha: CGFloat = 0
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                
                var topColor: UIColor? = colors.first
                if let first = colors.first {
                    first.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                    if alpha < 0.05 {
                        topColor = .clear
                    }
                }
                
                contentView.setGradientBackground(top: topColor ?? .clear,
                                                  bottom: colors.last ?? .clear)
            }
         }
    }
#endif
