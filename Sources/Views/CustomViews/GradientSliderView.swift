//
//  GradientSliderView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 08.02.2022.
//

#if os(macOS)
    import Cocoa

    final class GradientSliderView: StoryControl {
        override init(frame: NSRect) {
            super.init(frame: frame)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
#elseif os(iOS)
    import UIKit

    final class GradientSliderView: StoryControl {
        private var innerValue: CGFloat = 0
        var value: CGFloat {
            get { innerValue }
            set {
                innerValue = max(0, min(1, newValue))
                updateLayerFrames()
            }
        }

        var thumbImage = "\u{1f604}".imageFromEmoji()! {
            didSet {
                thumbImageView.image = thumbImage
                updateLayerFrames()
            }
        }

        var trackHeight: CGFloat = 11 {
            didSet { updateLayerFrames() }
        }
        
        var trackPosition: CGFloat { thumbImageView.frame.midX }
        
        private let thumbImageView = UIImageView()
        private let gradientLayer: CAGradientLayer = {
            let l = CAGradientLayer()
            l.startPoint = CGPoint(x: 0.0, y: 0.5)
            l.endPoint = CGPoint(x: 1.0, y: 0.5)
            l.masksToBounds = true
            l.colors = SRThemeColor.purple.gradient.map(\.cgColor)
            return l
        }()
        private let backgroundLayer: CALayer = {
            let l = CALayer()
            l.backgroundColor = SRThemeColor.black.cgColor
            l.opacity = 0.15
            return l
        }()
        private var previousLocation = CGPoint()

        override init(frame: CGRect) {
            super.init(frame: frame)
            self.prepare()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func prepare() {
            backgroundColor = .clear
            [backgroundLayer, gradientLayer].forEach(layer.addSublayer)
            thumbImageView.image = thumbImage
            addSubview(thumbImageView)
            layoutIfNeeded()
            isUserInteractionEnabled = true
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            backgroundLayer.frame = CGRect(
                x: 0,
                y: (bounds.height - trackHeight) / 2,
                width: bounds.width,
                height: trackHeight
            )
            gradientLayer.frame = CGRect(
                x: backgroundLayer.frame.minX,
                y: backgroundLayer.frame.minY,
                width: backgroundLayer.frame.width * innerValue,
                height: backgroundLayer.frame.height
            )
            backgroundLayer.cornerRadius = trackHeight / 2
            gradientLayer.cornerRadius = backgroundLayer.cornerRadius
        }
        
        func animateValue(to newValue: CGFloat, duration: TimeInterval) {
            let origin = self.thumbOriginForValue()
            if duration > .ulpOfOne {
                UIView.animate(withDuration: duration, animations: {
                    self.thumbImageView.frame.origin = origin
                }, completion: { _ in
                    self.value = newValue
                })
            } else {
                thumbImageView.frame.origin = origin
                value = newValue
            }
        }
        
        func updateLayerFrames() {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            thumbImageView.frame = CGRect(
                origin: thumbOriginForValue(),
                size: thumbImage.size
            )
            gradientLayer.frame = CGRect(
                x: backgroundLayer.frame.minX,
                y: backgroundLayer.frame.minY,
                width: backgroundLayer.frame.width * innerValue,
                height: backgroundLayer.frame.height
            )
            CATransaction.commit()
        }
        
        private func thumbOriginForValue() -> CGPoint {
            let x = bounds.width * innerValue - thumbImage.size.width / 2
            return CGPoint(x: x, y: -8)
        }
    }

    extension GradientSliderView {
        override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
            previousLocation = touch.location(in: self)
            let deltaX: CGFloat = 20
            let deltaY: CGFloat = 60
            
            var origin = thumbImageView.frame.origin
            origin.x -= deltaX / 2
            origin.y -= deltaY / 2
            
            var size = thumbImageView.frame.size
            size.width += deltaX
            size.height += deltaY
            
            let tmpFrame = CGRect(origin: origin, size: size)
            let success = tmpFrame.contains(previousLocation)
            sendActions(for: .editingDidBegin)
            return success
        }
        
        override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
            let location = touch.location(in: self)
            let deltaLocation = location.x - previousLocation.x
            let deltaValue = deltaLocation / bounds.width
            previousLocation = location
            value += deltaValue
            sendActions(for: .valueChanged)
            return true
        }
        
        override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
            guard let touch = touch else { return }
            let location = touch.location(in: self)
            let deltaLocation = location.x - previousLocation.x
            let deltaValue = deltaLocation / bounds.width
            previousLocation = location
            value += deltaValue
            sendActions(for: .valueChanged)
            sendActions(for: .editingDidEnd)
        }
    }
#endif
