//
//  SliderView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

protocol SliderViewDelegate: AnyObject {
    func didChooseSliderValue(_ widget: SliderView, value: Float)
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
    
    private let slider: GradientSliderView = {
        let slider = GradientSliderView()
        return slider
    }()
    
    private let emoji: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isHidden = true
        return iv
    }()

    private var emojiWidth: CGFloat = 34
    private var sliderPosY: CGFloat = 0
    
    init(story: SRStory, data: SRWidget, sliderWidget: SRSliderWidget) {
        self.sliderWidget = sliderWidget
        super.init(story: story, data: data)
    }
    
    override func addSubviews() {
        super.addSubviews()
        contentView.layer.addSublayer(gradientLayer)
        [centerView, titleLabel, emoji, slider].forEach(contentView.addSubview)
    }
    
    override func setupView() {
        super.setupView()
        gradientLayer.colors = sliderWidget.color.gradient.map(\.cgColor)
        slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderBeginChange(_:)), for: .editingDidBegin)
        slider.addTarget(self, action: #selector(sliderEndChange(_:)), for: .editingDidEnd)
        updateImage()
        titleLabel.text = sliderWidget.text
        if case .white = sliderWidget.color { titleLabel.textColor = .black }
    }
    
    func updateImage() {
        guard let result = UInt32(sliderWidget.emoji.unicode, radix: 16) else { return }
        guard let scalar = UnicodeScalar(result) else { return }
        let str = String(scalar)
        guard let image = str.imageFromEmoji(width: emojiWidth) else { return }
        slider.thumbImage = image
        emoji.image = image
    }
    
    override func setupContentLayer(_ layer: CALayer) {
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = contentView.bounds
        gradientLayer.cornerRadius = contentView.layer.cornerRadius
        
        let yScale = data.positionLimits.minHeight.map { bounds.height / CGFloat($0) } ?? 1
        updateFontSize(16 * yScale)
        
        let centerViewHeight: CGFloat = 11 * yScale
        let newEmojiWidth = centerViewHeight + 24
        let needUpdateEmoji = abs(emojiWidth - newEmojiWidth) > .ulpOfOne
        emojiWidth = newEmojiWidth
        if needUpdateEmoji { updateImage() }
        
        
        let padding: CGFloat = 20
        let spacing: CGFloat = 15
        var contentHeight: CGFloat = centerViewHeight
        var y = (bounds.height - contentHeight) / 2
        let width: CGFloat = max(0, bounds.width - padding * 2)
        if titleLabel.text != nil {
            let availableHeight: CGFloat = max(0, bounds.height - padding * 2 - centerViewHeight - spacing)
            let size = titleLabel.sizeThatFits(.init(width: width, height: availableHeight))
            let textHeight = min(size.height, availableHeight)
            contentHeight += spacing + textHeight
            y = (bounds.height - contentHeight) / 2
            titleLabel.frame = .init(x: padding, y: y, width: width, height: textHeight)
            y += textHeight + spacing
        }
        
        centerView.frame = .init(x: padding, y: y, width: width, height: centerViewHeight)
        centerView.layer.cornerRadius = centerView.bounds.height / 2
        slider.frame = centerView.frame.insetBy(dx: 0, dy: -12)
        
        slider.value = 0
        slider.animateValue(to: Float(sliderWidget.value) / 100, duration: 0.5)
        sliderPosY = slider.frame.origin.y
        changeEmojiFrame(for: CGFloat(sliderWidget.value / 100.0))
    }
    
    @objc func sliderBeginChange(_ sender: GradientSliderView) {
        NotificationCenter.default.post(name: .disableSwipe, object: nil)
        emoji.isHidden = false
        changeEmojiFrame(for: CGFloat(sender.value))
    }
    
    @objc func sliderChanged(_ sender: GradientSliderView) {
        changeEmojiFrame(for: CGFloat(sender.value))
    }
    
    @objc func sliderEndChange(_ sender: GradientSliderView) {
        sender.isUserInteractionEnabled = false
        hideEmoji()
    }
    
    private func updateFontSize(_ size: CGFloat) {
        titleLabel.font = .bold(ofSize: size)
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
        delegate?.didChooseSliderValue(self, value: slider.value)
        UIView.animate(
            withDuration: 0.5,
            animations: { [weak emoji] in
                emoji?.transform = CGAffineTransform.identity.scaledBy(x: 2.5, y: 2.5)
                emoji?.alpha = 0
            }
        )
    }
}
