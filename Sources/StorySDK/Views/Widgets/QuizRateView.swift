//
//  QuizRateView.swift
//  StorySDK
//
//  Created by Ingvarr Alef on 02.06.2023.
//

#if os(macOS)
    import Cocoa

    final class QuizRateView: SRInteractiveWidgetView {
        let widget: SRQuizRateWidget
        
        init(story: SRStory, data: SRWidget, widget: SRQuizRateWidget) {
            self.widget = widget
            super.init(story: story, data: data)
        }
    }
#elseif os(iOS)
    import UIKit

    final class QuizRateView: SRInteractiveWidgetView {
        let widget: SRQuizRateWidget
        
        private var disabledWidget: Bool = false
        
        private let headerLabel: UILabel = {
            let lbl = UILabel()
            lbl.font = .bold(ofSize: 12)
            lbl.textAlignment = .center
            
            return lbl
        }()
        
        lazy private var starsView: RateControl = {
            let stackView = RateControl(frame: .zero, starsNumber: 5)
            stackView.backgroundColor = .clear
            
            return stackView
        }()
        
        private let gradientLayer: CAGradientLayer = {
            let l = CAGradientLayer()
            l.startPoint = CGPoint(x: 0.0, y: 0.5)
            l.endPoint = CGPoint(x: 1.0, y: 0.5)
            l.masksToBounds = true
            return l
        }()

        private var answerViews = [EmojiAnswerView]()
        
        init(story: SRStory, data: SRWidget, widget: SRQuizRateWidget) {
            self.widget = widget
            super.init(story: story, data: data)
        }
        
        override func setupContentLayer(_ layer: CALayer) {
            layer.cornerRadius = 10
            layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = .zero
            layer.shadowRadius = 4
            layer.masksToBounds = true
        }
        
        override func addSubviews() {
            super.addSubviews()
            
            [gradientLayer].forEach(contentView.layer.addSublayer)
            [headerLabel, starsView].forEach(contentView.addSubview)
        }
        
        override func setupView() {
            super.setupView()
            headerLabel.text = widget.title
            headerLabel.textColor = SRThemeColor.white.color
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            let scale = widgetScale
            headerLabel.font = .bold(ofSize: 12 * scale)
            headerLabel.frame = .init(x: 0, y: 0, width: bounds.width, height: 41 * scale)
            gradientLayer.frame = headerLabel.frame
            
            starsView.frame = .init(x: 0, y: headerLabel.frame.maxY, width: bounds.width, height: 47)
        }
        
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            let scale = widgetScale
            let height: CGFloat = 200 * scale
            
            return CGSize(width: size.width, height: height)
        }
        
        override func setupWidget(reaction: String) {
        }
    }
#endif
