//
//  SliderView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

#if os(macOS)
    import Cocoa

    class SliderView: SRInteractiveWidgetView {
        let sliderWidget: SRSliderWidget
        
        init(story: SRStory, data: SRWidget, sliderWidget: SRSliderWidget) {
            self.sliderWidget = sliderWidget
            super.init(story: story, data: data)
        }
    }
#elseif os(iOS)
    import UIKit

    final class SliderExpandedView: UIView {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            isUserInteractionEnabled = true
        }
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            if self.point(inside: point, with: event) {
                return subviews.reversed().first
            }
            
            return nil
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class SliderView: SRInteractiveWidgetView {
        let sliderWidget: SRSliderWidget
        
        private let gradientLayer: CAGradientLayer = {
            let l = CAGradientLayer()
            l.startPoint = CGPoint(x: 0.0, y: 0.5)
            l.endPoint = CGPoint(x: 1.0, y: 0.5)
            l.masksToBounds = true
            return l
        }()
        
        private let sliderExpandedView: SliderExpandedView = {
            let v = SliderExpandedView()
            return v
        }()
        
        private let centerView: UIView = {
            let v = UIView()
            v.backgroundColor = .clear
            v.layer.masksToBounds = true
            return v
        }()
        
        private let titleLabel: UILabel = {
            let lb = UILabel()
            lb.font = .bold(ofSize: 16)
            lb.adjustsFontSizeToFitWidth = true
            lb.minimumScaleFactor = 0.5
            lb.textAlignment = .center
            lb.textColor = .white
            lb.numberOfLines = 0
            return lb
        }()
        
        private let slider = GradientSliderView()
        
        private let emoji: UIImageView = {
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.isHidden = true
            return iv
        }()

        private var emojiWidth: CGFloat = 34
        private var sliderPosY: CGFloat = 0
        
        init(story: SRStory, defaultStorySize: CGSize, data: SRWidget, sliderWidget: SRSliderWidget) {
            self.sliderWidget = sliderWidget
            super.init(story: story, defaultStorySize: defaultStorySize, data: data)
            
            slider.value = CGFloat(sliderWidget.value) / 100
        }
        
        override func addSubviews() {
            super.addSubviews()
            contentView.layer.addSublayer(gradientLayer)
            [sliderExpandedView].forEach(contentView.addSubview)
            
            [centerView, titleLabel, emoji, slider].forEach(sliderExpandedView.addSubview)
        }
        
        override func setupView() {
            super.setupView()
            gradientLayer.colors = sliderWidget.color.gradient.map(\.cgColor)
            slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
            slider.addTarget(self, action: #selector(sliderBeginChanged(_:)), for: .editingDidBegin)
            slider.addTarget(self, action: #selector(sliderEndChange(_:)), for: .editingDidEnd)
            updateImage()
            titleLabel.text = sliderWidget.text
            if case .white = sliderWidget.color { titleLabel.textColor = .black }
        }
        
        func updateImage() {
            guard let result = UInt32(sliderWidget.emoji.unicode, radix: 16) else { return }
            guard let scalar = UnicodeScalar(result) else { return }
            let str = String(scalar)
            guard let image = str.imageFromEmoji(fontSize: emojiWidth) else { return }
            slider.thumbImage = image
            emoji.image = image
        }
        
        override func setupContentLayer(_ layer: CALayer) {
            layer.cornerRadius = 10 * widgetScale
            layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = .zero
            layer.shadowRadius = 4
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            gradientLayer.frame = contentView.bounds
            gradientLayer.cornerRadius = contentView.layer.cornerRadius
            
            let scale = widgetScale
            titleLabel.font = .medium(ofSize: 16 * scale)
            
            let centerViewHeight: CGFloat = 11 * scale
            let newEmojiWidth = centerViewHeight + 24 * scale
            let needUpdateEmoji = abs(emojiWidth - newEmojiWidth) > .ulpOfOne
            emojiWidth = newEmojiWidth
            if needUpdateEmoji { updateImage() }
            
            let padding: CGFloat = 20 * scale
            let spacing: CGFloat = 15 * scale
            var contentHeight: CGFloat = centerViewHeight
            var y = (bounds.height - contentHeight) / 2
            let width: CGFloat = max(0, bounds.width - padding * 2)
            
            if let text = titleLabel.text {
                if !text.isEmpty {
                    var availableHeight: CGFloat = contentView.bounds.height
                    availableHeight -= padding * 2
                    availableHeight -= centerViewHeight
                    availableHeight -= spacing
                    availableHeight = max(0, availableHeight)
                    // let size = titleLabel.sizeThatFits(.init(width: width, height: availableHeight))
                    let textHeight = availableHeight // min(size.height, availableHeight)
                    contentHeight += spacing + textHeight
                    y = (bounds.height - contentHeight) / 2
                    titleLabel.frame = .init(x: padding, y: y, width: width, height: textHeight)
                    y += textHeight + spacing
                }
            }
            
            sliderExpandedView.frame = .init(x: 0, y: 0, width: bounds.width, height: bounds.height)
            
            centerView.frame = .init(x: padding, y: y, width: width, height: centerViewHeight)
            centerView.layer.cornerRadius = centerView.bounds.height / 2
            slider.frame = centerView.frame.insetBy(dx: 0, dy: -12 * scale)
            
            slider.animateValue(to: slider.value, duration: 0)
            sliderPosY = slider.frame.origin.y
            changeEmojiFrame(for: slider.value)
        }
        
        @objc func sliderBeginChanged(_ sender: GradientSliderView) {
            delegate?.didStartSlide()
            emoji.isHidden = false
            changeEmojiFrame(for: sender.value)
        }
        
        @objc func sliderChanged(_ sender: GradientSliderView) {
            changeEmojiFrame(for: sender.value)
        }
        
        @objc func sliderEndChange(_ sender: GradientSliderView) {
            delegate?.didFinishSlide()
            sender.isUserInteractionEnabled = false
            hideEmoji()
        }
        
        override func setupWidget(reaction: String) {
            guard let percents = Float(reaction) else { return }
            let value = CGFloat(percents) / 100
            slider.isUserInteractionEnabled = false
            slider.value = value
            slider.animateValue(to: value, duration: 0)
            changeEmojiFrame(for: CGFloat(value))
        }
    }

    // MARK: Big emoji
    extension SliderView {
        private func changeEmojiFrame(for value: CGFloat) {
            let scale: CGFloat = 1 + value
            let width = emojiWidth * (1 + value)
            let x = slider.frame.minX + slider.trackPosition
            let y = sliderPosY - 5 - width / 2
            emoji.center = CGPoint(x: x, y: y)
            emoji.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
        }
        
        private func hideEmoji() {
            delegate?.didChooseSliderValue(self, value: Float(slider.value))
            UIView.animate(
                withDuration: 0.5,
                animations: { [weak emoji] in
                    emoji?.transform = CGAffineTransform.identity.scaledBy(x: 2.5, y: 2.5)
                    emoji?.alpha = 0
                }
            )
        }
    }
#endif

protocol SliderViewDelegate: AnyObject {
    func didChooseSliderValue(_ widget: SliderView, value: Float)
    func didStartSlide()
    func didFinishSlide()
}

