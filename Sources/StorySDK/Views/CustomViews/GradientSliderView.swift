//
//  GradientSliderView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 08.02.2022.
//

import UIKit

final class GradientSliderView: UIControl {
    var value: Float = 0.0 {
        didSet {
            print("!!!", value)
            if value < 0 { value = 0 }
            updateLayerFrames()
        }
    }
    
    var maxValue: Float = 1.0 {
        didSet {
            if maxValue < 0 { maxValue = 0 }
            if maxValue > 1 { maxValue = 1 }
            updateLayerFrames()
        }
    }

    var thumbImage = "\u{1f604}".imageFromEmoji()! {
        didSet {
            thumbImageView.image = thumbImage
            updateLayerFrames()
        }
    }

    var trackHeight: CGFloat = 10 {
        didSet { updateLayerFrames() }
    }

    var trackHighlightStartTintColor = UIColor.sliderStart {
        didSet {
            trackLayer.startTintColor = trackHighlightStartTintColor.cgColor
            trackLayer.setNeedsDisplay()
        }
    }

    var trackHighlightFinishTintColor = UIColor.sliderFinish {
        didSet {
            trackLayer.finishTintColor = trackHighlightFinishTintColor.cgColor
            trackLayer.setNeedsDisplay()
        }
    }

    var trackTintColor = UIColor.sliderTint {
        didSet {
            trackLayer.tintColor = trackTintColor.cgColor
            trackLayer.setNeedsDisplay()
        }
    }
    
    var trackPosition: CGFloat { thumbImageView.frame.midX }
    
    private let thumbImageView = UIImageView()
    private let trackLayer = SliderTrackerLayer()
    private var previousLocation = CGPoint()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepare()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.prepare()
    }
    
    private func prepare() {
        backgroundColor = .clear
        trackLayer.slider = self
        trackLayer.contentsScale = UIScreen.main.scale
        trackLayer.cornerRadius = trackHeight / 2
        layer.addSublayer(trackLayer)
        thumbImageView.image = thumbImage
        addSubview(thumbImageView)
        layoutIfNeeded()
        isUserInteractionEnabled = true
    }
    
    func animateValue(to newValue: Float, duration: TimeInterval) {
        let origin = self.thumbOriginForValue(CGFloat(newValue))
        UIView.animate(withDuration: duration, animations: {
            self.thumbImageView.frame.origin = origin
        }, completion: {_ in
            self.value = newValue
        })
    }
    
    func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        trackLayer.frame = CGRect(
            x: 0,
            y: (bounds.size.height - trackHeight) / 2,
            width: bounds.size.width,
            height: trackHeight
        )
        trackLayer.setNeedsDisplay()
        thumbImageView.frame = CGRect(origin: thumbOriginForValue(CGFloat(value)),
                                      size: thumbImage.size)
        CATransaction.commit()
    }
    
    func positionForValue(_ value: CGFloat) -> CGFloat {
        if maxValue == 0 { return 0 }
        let divider = maxValue
        return bounds.width * value / CGFloat(divider)
    }
    
    private func thumbOriginForValue(_ value: CGFloat) -> CGPoint {
        let x = positionForValue(value) - thumbImage.size.width * value
        return CGPoint(x: x, y: (bounds.height - thumbImage.size.height * 1.06) / 2.0)
    }

}

extension GradientSliderView {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        let deltaX: CGFloat = 20
        var origin = thumbImageView.frame.origin
        origin.x -= deltaX / 2
        var size = thumbImageView.frame.size
        size.width += deltaX
        let tmpFrame = CGRect(origin: origin, size: size)
        let success = tmpFrame.contains(previousLocation)
                
        sendActions(for: .editingDidBegin)
        
        return success
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        let deltaLocation = location.x - previousLocation.x
        let deltaValue = CGFloat(maxValue) * deltaLocation / bounds.width

        previousLocation = location
        value += Float(deltaValue)
        value = boundValue(value, toLowerValue: 0, upperValue: maxValue)
        sendActions(for: .valueChanged)

        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        guard let touch = touch else { return }
        let location = touch.location(in: self)
        let deltaLocation = location.x - previousLocation.x
        let deltaValue = CGFloat(maxValue) * deltaLocation / bounds.width

        previousLocation = location
        value += Float(deltaValue)
        value = boundValue(value, toLowerValue: 0, upperValue: maxValue)
        sendActions(for: .valueChanged)
        sendActions(for: .editingDidEnd)
    }

    private func boundValue(_ value: Float, toLowerValue lowerValue: Float, upperValue: Float) -> Float {
        return min(max(value, lowerValue), upperValue)
    }
}

class SliderTrackerLayer: CALayer {
    weak var slider: GradientSliderView?
    let gradient = CAGradientLayer()
    let shapeMask = CAShapeLayer()
    
    var tintColor: CGColor = UIColor.sliderTint.cgColor
    var startTintColor: CGColor = UIColor.sliderStart.cgColor
    var finishTintColor: CGColor = UIColor.sliderFinish.cgColor

    override func draw(in ctx: CGContext) {
        guard let slider = slider else { return }

        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        ctx.addPath(path.cgPath)

        ctx.setFillColor(tintColor)
        ctx.fillPath()

        let value = CGFloat(slider.value)
        let width = slider.positionForValue(value)
        let rect = CGRect(x: 0, y: 0, width: width, height: bounds.height)

        ctx.setFillColor(startTintColor)
        
        let tintedPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        shapeMask.path = tintedPath.cgPath
        
        let colors = [startTintColor, finishTintColor]
        let cgColors = colors.map({ $0 })
        gradient.frame = self.bounds
        gradient.startPoint = CGPoint.zero
        gradient.endPoint = CGPoint(x: width / frame.width, y: 0)
        gradient.colors = cgColors
        gradient.mask = shapeMask
        self.addSublayer(gradient)
    }
}
