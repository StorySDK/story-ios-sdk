//
//  SRDefaultLoader.swift
//  StorySDK
//
//  Created by Ingvarr Alef on 03/05/2024.
//

import UIKit

public final class SRDefaultLoader: UIView, SRLoader, CAAnimationDelegate {
    public var isAnimating: Bool = false
    private var color: UIColor
    
    public init(color: UIColor = UIColor.white.withAlphaComponent(0.8)) {
        self.color = color
        super.init(frame: CGRect(x: 0, y: 0, width: 72, height: 72))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startAnimating() {
        guard !isAnimating else {
            return
        }
        
        isHidden = false
        isAnimating = true
        
        setupLoaderAnimation()
    }
    
    public func delay(_ delay: Double, closure: @escaping () -> Void) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }

    public func stopAnimating() {
        guard isAnimating else {
            return
        }
        
        isHidden = true
        isAnimating = false
        layer.sublayers?.removeAll()
    }
    
    private func setupLoaderAnimation() {
        layer.sublayers = nil
        
        var rect = frame.inset(by: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
        let minEdge = min(rect.width, rect.height)
        
        rect.size = CGSize(width: minEdge, height: minEdge)
        setupLoaderAnimation(in: layer, size: rect.size, color: color)
    }
    
    private func setupLoaderAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let duration: Double = 3.6

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.byValue = Float.pi * 2
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .linear)

        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [rotationAnimation]
        groupAnimation.duration = duration
        groupAnimation.repeatCount = .infinity
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards
        
        let circle = createLoaderLayer(size: size, color: color)
        let circleFrame = CGRect(
            x: (layer.bounds.width - size.width) / 2,
            y: (layer.bounds.height - size.height) / 2,
            width: size.width,
            height: size.height
        )

        circle.frame = circleFrame
        circle.add(groupAnimation, forKey: "loaderAnimation")
        layer.addSublayer(circle)
    }
    
    private func createLoaderLayer(size: CGSize, color: UIColor) -> CALayer {
         let layer: CAShapeLayer = CAShapeLayer()
         var path: UIBezierPath = UIBezierPath()
         let lineWidth: CGFloat = 4
        
        path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                    radius: size.width / 2,
                    startAngle: -(.pi / 2),
                    endAngle: .pi + .pi / 2 - (2.0 * .pi / 6),
                    clockwise: true)
        layer.fillColor = nil
        layer.strokeColor = color.cgColor
        layer.lineWidth = lineWidth
        layer.backgroundColor = nil
        layer.path = path.cgPath
        layer.frame = CGRect(x: 0, y: 0,
                             width: size.width, height: size.height)

        return layer
     }
}
