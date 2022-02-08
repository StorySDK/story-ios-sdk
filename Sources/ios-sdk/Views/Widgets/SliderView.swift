//
//  SliderView.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

class SliderView: UIView {
    private var story: Story!
    private var data: WidgetData!
    private var sliderWidget: SliderWidget!
    
    private lazy var centerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        
        return v
    }()
    
    private lazy var slider: GradientSliderView = {
        let slider = GradientSliderView()
        slider.translatesAutoresizingMaskIntoConstraints = false

        return slider
    }()
    
    private lazy var emoji: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        return iv
    }()

    private var emojiWidth: CGFloat = 34
    private var sliderPosY: CGFloat = 0
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func setNeedsLayout() {
        super.setNeedsLayout()
        DispatchQueue.main.async {
            self.slider.value = 0
            self.slider.animateValue(to: Float(self.sliderWidget.value) / 100, duration: 0.5)
            self.sliderPosY = self.slider.frame.origin.y
            self.changeEmojiFrame(for: CGFloat(self.sliderWidget.value / 100.0))
        }
    }
    
    convenience init(frame: CGRect, story: Story, data: WidgetData, sliderWidget: SliderWidget) {
        self.init(frame: frame)
        self.story = story
        self.data = data
        self.sliderWidget = sliderWidget
        self.transform = CGAffineTransform.identity.rotated(by: data.position.rotate * .pi / 180)
        prepareUI()
    }
    
    private func prepareUI() {
        backgroundColor = .clear
        layer.cornerRadius = 10
        layer.shadowColor = black.withAlphaComponent(0.15).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4
        var scaleFactor: CGFloat = 1 //xScaleFactor
        if let minWidth = data.positionLimits.minWidth {
            scaleFactor *= frame.width / CGFloat(minWidth)
        }
        emojiWidth *= scaleFactor
        
        if sliderWidget.color == "purple" {
            let colors = [purpleStart, purpleFinish]
            let points = [CGPoint(x: 0.02, y: 0), CGPoint(x: 0.96, y: 0)]
            let l = Utils.getGradient(frame: bounds, colors: colors, points: points)
            l.cornerRadius = 10
            layer.insertSublayer(l, at: 0)
        }
        else {
            backgroundColor = Utils.getSolidColor(sliderWidget.color)
        }

        addSubview(centerView)
        NSLayoutConstraint.activate([
            centerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            centerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            centerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20)
        ])
        
        centerView.addSubview(emoji)
        emoji.isHidden = true

        centerView.addSubview(slider)
        NSLayoutConstraint.activate([
            slider.heightAnchor.constraint(equalToConstant: emojiWidth),
            slider.rightAnchor.constraint(equalTo: centerView.rightAnchor),
            slider.leftAnchor.constraint(equalTo: centerView.leftAnchor),
            slider.bottomAnchor.constraint(equalTo: centerView.bottomAnchor)
        ])
        
        slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderBeginChange(_:)), for: .editingDidBegin)
        slider.addTarget(self, action: #selector(sliderEndChange(_:)), for: .editingDidEnd)
        if let result = UInt32(sliderWidget.emoji.unicode, radix: 16), let scalar = UnicodeScalar(result) {
            let str = String(scalar)
            if let image = str.imageFromEmoji(width: emojiWidth) {
                slider.thumbImage = image
                emoji.image = image
            }
        }
        slider.trackHeight *= scaleFactor
        
        if let text = sliderWidget.text {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.getFont(name: "Inter-Bold", size: 16 * scaleFactor)
            label.text = text
            label.textAlignment = .center
            if sliderWidget.color == "white" {
                label.textColor = black
            }
            else {
                label.textColor = .white
            }
            centerView.insertSubview(label, belowSubview: emoji)
            NSLayoutConstraint.activate([
                label.rightAnchor.constraint(equalTo: centerView.rightAnchor),
                label.leftAnchor.constraint(equalTo: centerView.leftAnchor),
                label.topAnchor.constraint(equalTo: centerView.topAnchor),
                label.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -15)
            ])
        }
    }
    
    @objc func sliderBeginChange(_ sender: GradientSliderView) {
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: disableSwipeNotificanionName), object: nil)
        emoji.isHidden = false
    }
    
    @objc func sliderChanged(_ sender: GradientSliderView) {
        changeEmojiFrame(for: CGFloat(sender.value))
    }
    
    @objc func sliderEndChange(_ sender: GradientSliderView) {
        sender.isUserInteractionEnabled = false
        hideEmoji()
    }
}

//MARK: Big emoji
extension SliderView {
    private func changeEmojiFrame(for value: CGFloat) {
        let scale: CGFloat = 1 + value
        let width = emojiWidth * (1 + value)
        let x = centerView.frame.width * value - emojiWidth * (value - 0.5)
        let y = sliderPosY - 5 - width / 2
        emoji.center = CGPoint(x: x, y: y)
        emoji.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
    }
    
    private func hideEmoji() {
        UIView.animate(withDuration: 0.5, animations: {
            self.emoji.transform = CGAffineTransform.identity.scaledBy(x: 2.5, y: 2.5)
            self.emoji.alpha = 0
        }, completion: {_ in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: sendStatisticNotificationName), object: nil, userInfo: [
                widgetTypeParam: statisticAnswerParam,
                groupIdParam: self.story.group_id,
                storyIdParam: self.story.id,
                widgetIdParam: self.data.id,
                widgetValueParam: "\(Int(self.slider.value * 100))%"
            ])
        })
    }
}
