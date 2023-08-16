//
//  SRClickMeView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

#if os(macOS)
    import Cocoa

    class SRClickMeView: SRImageWidgetView {
        let clickMeWidget: SRClickMeWidget
        
        init(story: SRStory, data: SRWidget, clickMeWidget: SRClickMeWidget, imageUrl: URL?, loader: SRImageLoader, logger: SRLogger) {
            self.clickMeWidget = clickMeWidget
            super.init(story: story, data: data, url: imageUrl, loader: loader, logger: logger)
        }
    }
#elseif os(iOS)
    import UIKit

    class SRClickMeView: SRImageWidgetView {
        let clickMeWidget: SRClickMeWidget
        
        var bgColor = UIColor.clear
        var gradientColors: [UIColor] = []
        var gradientSetup: Bool = false
        
        private let headerLabel: UILabel = {
            let lbl = UILabel()
            lbl.textAlignment = .center
            
            return lbl
        }()
        
        init(story: SRStory, data: SRWidget, clickMeWidget: SRClickMeWidget, imageUrl: URL?, loader: SRImageLoader, logger: SRLogger) {
            self.clickMeWidget = clickMeWidget
            super.init(story: story, data: data, url: imageUrl, loader: loader, logger: logger)
        }
        
        override func setupContentLayer(_ layer: CALayer) {
            layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = .zero
            layer.shadowRadius = 4
            layer.masksToBounds = true
        }
        
        override func setupView() {
            super.setupView()
            contentView.addSubview(headerLabel)
            
            switch clickMeWidget.backgroundColor {
            case .color(let color, _):
                bgColor = color
            case .gradient(let grColors, _):
                gradientColors = grColors
            default:
                break
            }
            
            gradientSetup = false
            
            if gradientColors.count > 1 {
            } else {
                contentView.backgroundColor = bgColor
            }
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
            addGestureRecognizer(tapGesture)
            
            headerLabel.text = clickMeWidget.text
            
            var textColor = UIColor.clear
            switch clickMeWidget.color {
            case .color(let color, _):
                textColor = color
            default:
                break
            }
            
            headerLabel.textColor = textColor
            headerLabel.font = .improvedFont(family: clickMeWidget.fontFamily, ofSize: clickMeWidget.fontSize, weight: clickMeWidget.fontParams.weight)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            if gradientColors.count > 1 && !gradientSetup && contentView.frame.width > .ulpOfOne {
                contentView.setGradientBackground(top: gradientColors.first ?? bgColor, bottom: gradientColors.last ?? bgColor)
                gradientSetup = true
            }
            
            if contentView.bounds.width > .ulpOfOne {
                contentView.layer.cornerRadius = min(clickMeWidget.borderRadius / 2, contentView.bounds.height / 2)
                
                headerLabel.frame = contentView.bounds
            }
        }
        
        @objc private func onTap(_ sender: Any) {
            animateView(onCompleted: { [weak self] in
                guard let wSelf = self else { return }
                wSelf.delegate?.didClickButton(wSelf)
            })
        }
        
        private func animateView(onCompleted: (() -> Void)? ) {
            UIView.animate(
                withDuration: SRConstants.animationsDuration / 2.0,
                animations: { [weak self] in
                    self?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                },
                completion: { [weak self] _ in
                    UIView.animate(
                        withDuration: SRConstants.animationsDuration / 2.0,
                        animations: { self?.transform = .identity },
                        completion: { _ in
                            onCompleted?()
                        }
                    )
                }
            )
        }
    }
#endif

protocol SRClickMeViewDelegate: AnyObject {
    func didClickButton(_ widget: SRClickMeView)
}
