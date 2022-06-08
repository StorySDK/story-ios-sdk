//
//  EmojiReactionView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

protocol EmojiReactionViewDelegate: AnyObject {
    func didChooseEmojiReaction(_ widget: EmojiReactionView, emoji: String)
}

class EmojiReactionView: SRInteractiveWidgetView {
    let emojiReactionWidget: SREmojiReactionWidget
    private var emojiViews = [UIImageView]()
    
    init(story: SRStory, data: SRWidget, emojiReactionWidget: SREmojiReactionWidget) {
        self.emojiReactionWidget = emojiReactionWidget
        super.init(story: story, data: data)
        prepareUI(scale: widgetScale)
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
        let emojiWidth: CGFloat = 34 * widgetScale
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
        contentView.backgroundColor = emojiReactionWidget.color.color
        
        let emojiWidth: CGFloat = 34 * scale
        for i in 0 ..< emojiReactionWidget.emoji.count {
            guard let result = UInt32(emojiReactionWidget.emoji[i].unicode, radix: 16),
                  let str = UnicodeScalar(result).map({ String($0) }),
                  let image = str.imageFromEmoji(width: emojiWidth) else { continue }
            let iv = UIImageView(image: image)
            iv.tag = i
            let tapgesture = UITapGestureRecognizer(target: self, action: #selector(emojiClicked(_:)))
            iv.addGestureRecognizer(tapgesture)
            iv.isUserInteractionEnabled = true
            emojiViews.append(iv)
            contentView.addSubview(iv)
        }
    }
    
    @objc private func emojiClicked(_ sender: UITapGestureRecognizer) {
        isUserInteractionEnabled = false
        NotificationCenter.default.post(name: .disableSwipe, object: nil)
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
