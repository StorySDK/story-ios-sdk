//
//  ConfettiView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 13.02.2022.
//

import UIKit
import QuartzCore

public class ConfettiView: UIView {

    public enum ConfettiType {
        case confetti, triangle, star, diamond
        case image(UIImage)
    }

    var emitter: CAEmitterLayer = CAEmitterLayer()
    public var colors: [UIColor] = [
        UIColor(red: 0.95, green: 0.40, blue: 0.27, alpha: 1.0),
        UIColor(red: 1.00, green: 0.78, blue: 0.36, alpha: 1.0),
        UIColor(red: 0.48, green: 0.78, blue: 0.64, alpha: 1.0),
        UIColor(red: 0.30, green: 0.76, blue: 0.85, alpha: 1.0),
        UIColor(red: 0.58, green: 0.39, blue: 0.55, alpha: 1.0),
    ]
    public var intensity: Float = 0.5
    public var type: ConfettiType = .diamond
    public private(set) var isActive: Bool = false

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func setup() {
        backgroundColor = .clear
    }

    public func startConfetti() {
        emitter = CAEmitterLayer()

        emitter.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: 0)
        emitter.emitterShape = CAEmitterLayerEmitterShape.line
        emitter.emitterSize = CGSize(width: frame.size.width, height: 1)

        var cells = [CAEmitterCell]()
        for color in colors {
            cells.append(confettiWithColor(color: color))
        }

        emitter.emitterCells = cells
        layer.addSublayer(emitter)
        isActive = true
    }

    public func stopConfetti() {
        emitter.birthRate = 0
        isActive = false
    }

    func imageForType(type: ConfettiType) -> UIImage? {
        let fileName: String
        switch type {
        case .confetti: fileName = "confetti"
        case .triangle: fileName = "triangle"
        case .star: fileName = "star"
        case .diamond: fileName = "diamond"
        case .image(let customImage): return customImage
        }
        return  UIImage(named: fileName, in: Bundle(for: ConfettiView.self), compatibleWith: nil)
    }

    func confettiWithColor(color: UIColor) -> CAEmitterCell {
        let confetti = CAEmitterCell()
        confetti.birthRate = 6.0 * intensity
        confetti.lifetime = 14.0 * intensity
        confetti.lifetimeRange = 0
        confetti.color = color.cgColor
        confetti.velocity = CGFloat(350.0 * intensity)
        confetti.velocityRange = CGFloat(80.0 * intensity)
        confetti.emissionLongitude = CGFloat(Double.pi)
        confetti.emissionRange = CGFloat(Double.pi)
        confetti.spin = CGFloat(3.5 * intensity)
        confetti.spinRange = CGFloat(4.0 * intensity)
        confetti.scaleRange = CGFloat(intensity)
        confetti.scaleSpeed = CGFloat(-0.1 * intensity)
        confetti.contents = imageForType(type: type)!.cgImage
        return confetti
    }
}
