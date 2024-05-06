//
//  SREllipseView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

#if os(macOS)
    import Cocoa

    class SREllipseView: SRImageWidgetView {
        let ellipseWidget: SREllipseWidget
        
        init(story: SRStory, data: SRWidget, ellipseWidget: SREllipseWidget, imageUrl: URL?, loader: SRImageLoader, logger: SRLogger) {
            self.ellipseWidget = ellipseWidget
            super.init(story: story, data: data, url: imageUrl, loader: loader, logger: logger)
        }
    }
#elseif os(iOS)
    import UIKit

    class SREllipseView: SRImageWidgetView {
        let ellipseWidget: SREllipseWidget

        init(story: SRStory, defaultStorySize: CGSize, data: SRWidget, ellipseWidget: SREllipseWidget, imageUrl: URL?, loader: SRImageLoader, logger: SRLogger) {
            self.ellipseWidget = ellipseWidget
            super.init(story: story, defaultStorySize: defaultStorySize, data: data, url: imageUrl, loader: loader, logger: logger)
        }
        
        override func setupView() {
            super.setupView()
            // guard url == nil else { return }
            if case .color(let color, let isFilled) = ellipseWidget.fillColor {
                let fillOpacity = CGFloat(ellipseWidget.fillOpacity / 100)
                contentView.backgroundColor = color
            }
            if ellipseWidget.hasBorder, case .color(let color, let isFilled) = ellipseWidget.strokeColor {
                let strokeOpacity = CGFloat(ellipseWidget.strokeOpacity / 100)
                contentView.layer.borderColor = color
                    .withAlphaComponent(strokeOpacity)
                    .cgColor
                contentView.layer.borderWidth = CGFloat(ellipseWidget.strokeThickness)
            }
            isUserInteractionEnabled = false
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            contentView.layer.cornerRadius = frame.height / 2
            CATransaction.commit()
        }
    }
#endif
