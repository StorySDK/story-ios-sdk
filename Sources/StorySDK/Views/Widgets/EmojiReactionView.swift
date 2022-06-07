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
    let emojiReactionWidget: EmojiReactionWidget
    private var emojiViews = [UIImageView]()
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        sv.alignment = .center
        return sv
    }()

    init(story: SRStory, data: SRWidget, emojiReactionWidget: EmojiReactionWidget, scale: CGFloat) {
        self.emojiReactionWidget = emojiReactionWidget
        super.init(story: story, data: data)
        prepareUI(scale: scale)
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
    }
    
    private func prepareUI(scale: CGFloat) {
        contentView.backgroundColor = emojiReactionWidget.color.color
        
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 22 * xScaleFactor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -22 * xScaleFactor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        let emojiWidth: CGFloat = 34 * scale
        for i in 0 ..< emojiReactionWidget.emoji.count {
            if let result = UInt32(emojiReactionWidget.emoji[i].unicode, radix: 16), let scalar = UnicodeScalar(result) {
                let str = String(scalar)
                if let image = str.imageFromEmoji(width: emojiWidth) {
                    let iv = UIImageView(image: image)
                    iv.tag = i
                    let tapgesture = UITapGestureRecognizer(target: self, action: #selector(emojiClicked(_:)))
                    iv.addGestureRecognizer(tapgesture)
                    iv.isUserInteractionEnabled = true
                    emojiViews.append(iv)
                    stackView.addArrangedSubview(iv)
                }
            }
        }
    }
    
    @objc private func emojiClicked(_ sender: UITapGestureRecognizer) {
        isUserInteractionEnabled = false
        NotificationCenter.default.post(name: .disableSwipe, object: nil)
        if let v = sender.view as? UIImageView {
            hideEmoji(number: v.tag)
        }
    }
    
    private func hideEmoji(number: Int) {
        let ev = emojiViews[number]
        let rect = self.convert(ev.frame, from: stackView)
        let emoji = UIImageView(frame: rect)
        emoji.translatesAutoresizingMaskIntoConstraints = true
        emoji.image = ev.image
        insertSubview(emoji, belowSubview: stackView)
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
