//
//  EmojiReactionView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

#if os(macOS)
    import Cocoa

    class EmojiReactionView: SRInteractiveWidgetView {
        let emojiReactionWidget: SREmojiReactionWidget
        
        init(story: SRStory, data: SRWidget, emojiReactionWidget: SREmojiReactionWidget) {
            self.emojiReactionWidget = emojiReactionWidget
            super.init(story: story, data: data)
        }
    }
#elseif os(iOS)
    import UIKit

    class EmojiReactionView: SRInteractiveWidgetView {
        let emojiReactionWidget: SREmojiReactionWidget
        private var emojiViews = [UIImageView]()
        private let gradientLayer: CAGradientLayer = {
            let l = CAGradientLayer()
            l.startPoint = CGPoint(x: 0.0, y: 0.5)
            l.endPoint = CGPoint(x: 1.0, y: 0.5)
            l.masksToBounds = true
            return l
        }()
        
        override var widgetScale: CGFloat {
            data.positionLimits.minHeight.map { data.getWidgetPosition(storySize: defaultStorySize).realHeight / $0 } ?? 1
        }
        
        init(story: SRStory, defaultStorySize: CGSize, data: SRWidget, emojiReactionWidget: SREmojiReactionWidget) {
            self.emojiReactionWidget = emojiReactionWidget
            super.init(story: story, defaultStorySize: defaultStorySize, data: data)
            prepareUI(scale: widgetScale)
        }
        
        override func addSubviews() {
            super.addSubviews()
            contentView.layer.addSublayer(gradientLayer)
        }
        
        override func setupView() {
            super.setupView()
            isUserInteractionEnabled = true
        }
        
        override func setupContentLayer(_ layer: CALayer) {
            layer.masksToBounds = false
            layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = .zero
            layer.shadowRadius = 4
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            contentView.layer.cornerRadius = contentView.frame.height / 2
            gradientLayer.frame = contentView.bounds
            gradientLayer.cornerRadius = contentView.layer.cornerRadius
            let emojiWidth: CGFloat = bounds.height * 0.6 // 34 * widgetScale
            let padding = contentView.layer.cornerRadius - emojiWidth / 2
            let contentWidth = contentView.frame.width - padding * 2
            let spacing = (contentWidth - emojiWidth * CGFloat(emojiViews.count)) / max(0, CGFloat(emojiViews.count - 1))
            let y = (contentView.frame.height - emojiWidth) / 2
            for index in 0..<emojiViews.count {
                emojiViews[index].frame = .init(
                    x: padding + (emojiWidth + spacing) * CGFloat(index),
                    y: y,
                    width: emojiWidth,
                    height: emojiWidth
                )
            }
        }
        
        private func prepareUI(scale: CGFloat) {
            gradientLayer.colors = emojiReactionWidget.color.gradient.map(\.cgColor)
            
            let emojiWidth: CGFloat = 34 * scale
            for i in 0 ..< emojiReactionWidget.emoji.count {
                let scalars = emojiReactionWidget.emoji[i].unicode
                    .split(separator: "-")
                    .compactMap { UInt32($0, radix: 16) }
                    .compactMap { UnicodeScalar($0) }
                var str = ""
                str.unicodeScalars.append(contentsOf: scalars)
                guard !str.isEmpty,
                      let image = str.imageFromEmoji(fontSize: emojiWidth) else { continue }
                let iv = UIImageView(image: image)
                let tapgesture = UITapGestureRecognizer(target: self, action: #selector(emojiClicked(_:)))
                iv.addGestureRecognizer(tapgesture)
                iv.isUserInteractionEnabled = true
                emojiViews.append(iv)
                contentView.addSubview(iv)
                iv.tag = emojiViews.count - 1
            }
        }
        
        @objc private func emojiClicked(_ sender: UITapGestureRecognizer) {
            isUserInteractionEnabled = false
            (sender.view as? UIImageView).map { hideEmoji(number: $0.tag) }
        }
        
        override func setupWidget(reaction: String) {
            isUserInteractionEnabled = false
        }
        
        private func hideEmoji(number: Int) {
            let ev = emojiViews[number]
            let rect = self.convert(ev.frame, from: contentView)
            let emoji = UIImageView(frame: rect)
            emoji.translatesAutoresizingMaskIntoConstraints = true
            emoji.image = ev.image
            contentView.addSubview(emoji)
            setNeedsLayout()
            delegate?.didChooseEmojiReaction(self, emoji: emojiReactionWidget.emoji[number].unicode)
            UIView.animate(
                withDuration: 0.5,
                animations: {
                    emoji.transform = CGAffineTransform.identity
                        .scaledBy(x: 1.5, y: 1.5)
                        .translatedBy(x: 0, y: -self.frame.height / 2)
                    emoji.alpha = 0
                },
                completion: { _ in emoji.removeFromSuperview() }
            )
        }
    }

#endif

protocol EmojiReactionViewDelegate: AnyObject {
    func didChooseEmojiReaction(_ widget: EmojiReactionView, emoji: String)
}
