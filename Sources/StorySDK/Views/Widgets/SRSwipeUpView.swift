//
//  SRSwipeUpView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

#if os(macOS)
    import Cocoa

    class SRSwipeUpView: SRImageWidgetView {
        let swipeUpWidget: SRSwipeUpWidget
        
        init(story: SRStory, data: SRWidget, swipeUpWidget: SRSwipeUpWidget, imageUrl: URL?, loader: SRImageLoader, logger: SRLogger) {
            self.swipeUpWidget = swipeUpWidget
            super.init(story: story, data: data, url: imageUrl, loader: loader, logger: logger)
        }
    }
#elseif os(iOS)
    import UIKit

    class SRSwipeUpView: SRImageWidgetView {
        let swipeUpWidget: SRSwipeUpWidget
        
        private let iconView: UIImageView = {
            let v = UIImageView(image: UIImage(systemName: "chevron.up.circle"))
            v.tintColor = .white
            v.contentMode = .scaleAspectFit
            v.isUserInteractionEnabled = false
            return v
        }()
        private let titleLabel: UILabel = {
            let v = UILabel()
            v.textAlignment = .center
            v.textColor = .white
            v.adjustsFontSizeToFitWidth = true
            v.minimumScaleFactor = 0.5
            return v
        }()

        init(story: SRStory, defaultStorySize: CGSize, data: SRWidget, swipeUpWidget: SRSwipeUpWidget, imageUrl: URL?, loader: SRImageLoader, logger: SRLogger) {
            self.swipeUpWidget = swipeUpWidget
            super.init(story: story, defaultStorySize: defaultStorySize, data: data, url: imageUrl, loader: loader, logger: logger)
        }
        
        override func addSubviews() {
            super.addSubviews()
            [iconView, titleLabel].forEach(contentView.addSubview)
        }
        
        override func setupView() {
            super.setupView()
            
            alpha = swipeUpWidget.opacity / 100
            titleLabel.text = swipeUpWidget.text
            titleLabel.font = .regular(ofSize: swipeUpWidget.fontSize)
            
            if case .color(let color, let isFilled) = swipeUpWidget.color {
                iconView.tintColor = color
                titleLabel.textColor = color
            }
            
            if let name = swipeUpWidget.icon.systemIconName {
                iconView.image = UIImage(systemName: name)
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            let iconSize = bounds.height * swipeUpWidget.iconSize / data.getWidgetPosition(storySize: defaultStorySize).realHeight
            let fontSize = bounds.height * swipeUpWidget.fontSize / data.getWidgetPosition(storySize: defaultStorySize).realHeight
            titleLabel.font = .regular(ofSize: fontSize)
            iconView.frame = .init(
                x: 0, y: 0,
                width: bounds.width,
                height: iconSize)
            let y = iconView.frame.maxY
            titleLabel.frame = .init(
                x: 0, y: y,
                width: bounds.width,
                height: max(0, bounds.height - y))
        }
    }
#endif

protocol SRSwipeUpViewDelegate: AnyObject {
    func didSwipeUp(_ widget: SRSwipeUpView) -> Bool
}
