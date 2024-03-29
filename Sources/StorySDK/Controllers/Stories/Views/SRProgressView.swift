//
//  SRProgressView.swift
//  
//
//  Created by Aleksei Cherepanov on 20.05.2022.
//

#if os(macOS)
    import Cocoa

    final class SRProgressView: StoryView {
        
        init() {
            super.init(frame: .zero)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
#elseif os(iOS)
    import UIKit

    final class SRProgressView: StoryView, SRProgressComponent {
        override var intrinsicContentSize: CGSize {
            .init(width: CGFloat.greatestFiniteMagnitude, height: 3)
        }
        private let maskLayer = ProgressMaskLayer()
        private let fillLayer = CALayer()
        
        override var tintColor: UIColor! {
            didSet { fillLayer.backgroundColor = tintColor.withAlphaComponent(0.7).cgColor }
        }
        
        var numberOfItems: Int {
            get { maskLayer.numberOfItems }
            set {
                maskLayer.numberOfItems = newValue
                layer.mask
            }
        }
        
        var progress: Float = 0 {
            didSet {
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
        
        var activeColor: UIColor {
            get { tintColor }
            set { tintColor = newValue }
        }
        var animationDuration: TimeInterval = 0.3
        
        init() {
            super.init(frame: .zero)
            layer.backgroundColor = UIColor.white.withAlphaComponent(0.3).cgColor
            layer.mask = maskLayer
            layer.addSublayer(fillLayer)
            fillLayer.backgroundColor = tintColor.withAlphaComponent(0.7).cgColor
        }
        
        public func setupInLoadingState(info: HeaderInfo) {
            activeColor = .white.withAlphaComponent(0.75)
            progress = 0.0
            numberOfItems = info.storiesCount
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            maskLayer.frame = bounds
            CATransaction.begin()
            CATransaction.setValue(NSNumber(value: animationDuration),
                                   forKey: kCATransactionAnimationDuration)
            CATransaction.setValue(CAMediaTimingFunction(name: .linear),
                                   forKey: kCATransactionAnimationTimingFunction)
            fillLayer.frame = .init(
                x: 0,
                y: 0,
                width: bounds.width * CGFloat(progress),
                height: bounds.height
            )
            CATransaction.commit()
        }
    }

    private final class ProgressMaskLayer: CALayer {
        var numberOfItems: Int = 0 {
            didSet {
                guard oldValue != numberOfItems else { return }
                
                setNeedsDisplay()
                displayIfNeeded()
            }
        }
        
        override func draw(in ctx: CGContext) {
            guard numberOfItems > 0 else { return }
            
            let spacing: CGFloat = bounds.height
            var itemWidth = bounds.width
            itemWidth -= CGFloat(numberOfItems - 1) * spacing
            itemWidth /= CGFloat(numberOfItems)
            
            for i in 0..<numberOfItems {
                let rect = CGRect(
                    x: CGFloat(i) * (itemWidth + spacing),
                    y: 0,
                    width: itemWidth,
                    height: bounds.height
                )
                let path = UIBezierPath(roundedRect: rect, cornerRadius: bounds.height / 2)
                ctx.addPath(path.cgPath)
            }
            ctx.fillPath()
        }
    }
#endif
