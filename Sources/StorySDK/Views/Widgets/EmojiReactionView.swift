//
//  EmojiReactionView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

class EmojiReactionView: UIView {
    /*
     const INIT_ELEMENT_STYLES = {
       widget: {
         borderRadius: 50,
         paddingTop: 14,
         paddingBottom: 14,
         paddingRight: 11,
         paddingLeft: 11
       },
       emoji: {
         width: 34
       },
       item: {
         marginRight: 11,
         marginLeft: 11
       }
     };

     */
    private var story: Story!
    private var data: WidgetData!
    private var emojiReactionWidget: EmojiReactionWidget!
    
    private var emojiViews = [UIImageView]()
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        sv.alignment = .center

        return sv
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(frame: CGRect, story: Story, data: WidgetData, emojiReactionWidget: EmojiReactionWidget, scale: CGFloat) {
        self.init(frame: frame)
        self.story = story
        self.data = data
        self.emojiReactionWidget = emojiReactionWidget
        self.transform = CGAffineTransform.identity.rotated(by: data.position.rotate * .pi / 180)
        isUserInteractionEnabled = true
        backgroundColor = .clear
        layer.cornerRadius = frame.height / 2
        clipsToBounds = false
        layer.shadowColor = black.withAlphaComponent(0.15).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4
        prepareUI(scale: scale)
    }
    
    private func prepareUI(scale: CGFloat) {
        if emojiReactionWidget.color == "purple" {
            let colors = [purpleStart, purpleFinish]
            let points = [CGPoint(x: 0.02, y: 0), CGPoint(x: 0.96, y: 0)]
            let l = Utils.getGradient(frame: bounds, colors: colors, points: points)
            l.cornerRadius = 10
            layer.insertSublayer(l, at: 0)
        } else {
            backgroundColor = Utils.getSolidColor(emojiReactionWidget.color)
        }
        
        addSubview(stackView)
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
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: disableSwipeNotificanionName), object: nil)
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
        UIView.animate(withDuration: 0.5, animations: {
            emoji.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5).translatedBy(x: 0, y: -self.frame.height / 2)
            emoji.alpha = 0
        }, completion: {_ in
            emoji.removeFromSuperview()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: sendStatisticNotificationName), object: nil, userInfo: [
                widgetTypeParam: statisticClickParam,
                groupIdParam: self.story.group_id,
                storyIdParam: self.story.id,
                widgetIdParam: self.data.id,
                widgetValueParam: self.emojiReactionWidget.emoji[number].unicode,
            ])
        })
    }
}
