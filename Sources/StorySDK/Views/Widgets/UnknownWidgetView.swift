//
//  UnknownWidgetView.swift
//  StorySDK
//
//  Created by Ingvarr Alef on 14.05.2023.
//

#if os(macOS)
    import Cocoa

    class UnknownWidgetView: SRInteractiveWidgetView {
        let widget: SRUnknownWidget
        
        init(story: SRStory, data: SRWidget, widget: SRUnknownWidget) {
            self.widget = widget
            super.init(story: story, data: data)
        }
    }
#elseif os(iOS)
    import UIKit

    class UnknownWidgetView: SRInteractiveWidgetView {
        let widget: SRUnknownWidget
        
        private let grayView: UIView = {
            let v = UIView()
            v.backgroundColor = SRThemeColor.grey.color
            return v
        }()
        
        private let titleLabel: UILabel = {
            let l = UILabel()
            l.numberOfLines = 0
            l.textAlignment = .center
            l.textColor = SRThemeColor.white.color
            return l
        }()
        
        init(story: SRStory, data: SRWidget, widget: SRUnknownWidget) {
            self.widget = widget
            super.init(story: story, data: data)
        }
        
        override func setupView() {
            super.setupView()
            [titleLabel, grayView].forEach(contentView.addSubview)
            titleLabel.text = widget.title
        }
        
        override func setupContentLayer(_ layer: CALayer) {
            layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = .zero
            layer.shadowRadius = 4
            layer.masksToBounds = true
            layer.cornerRadius = 8
            layer.backgroundColor = UIColor.lightGray.cgColor
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            let scale = widgetScale
            titleLabel.font = .bold(ofSize: 14 * scale)
            titleLabel.frame = .init(x: 0,
                                     y: 0,
                                     width: contentView.frame.width,
                                     height: 44)
        }
    }
#endif
