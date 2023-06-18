//
//  SRClickMeView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

protocol SRClickMeViewDelegate: AnyObject {
    func didClickButton(_ widget: SRClickMeView)
}

class SRClickMeView: SRImageWidgetView {
    let clickMeWidget: SRClickMeWidget
    
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
        
        var bgColor = UIColor.clear
        switch clickMeWidget.backgroundColor {
        case .color(let color, _):
            bgColor = color
        default:
            break
        }
        
        contentView.backgroundColor = bgColor
        
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
        contentView.layer.cornerRadius = min(clickMeWidget.borderRadius / UIScreen.main.scale, data.position.realHeight / (2 * UIScreen.main.scale))
        
        headerLabel.frame = contentView.bounds
    }
    
    @objc private func onTap(_ sender: Any) {
        animateView(onCompleted: { [weak self] in
            guard let wSelf = self else { return }
            wSelf.delegate?.didClickButton(wSelf)
        })
    }
    
    private func animateView(onCompleted: (() -> Void)? ) {
        UIView.animate(
            withDuration: .animationsDuration,
            animations: { [weak self] in
                self?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            },
            completion: { [weak self] _ in
                UIView.animate(
                    withDuration: .animationsDuration,
                    animations: { self?.transform = .identity },
                    completion: { _ in
                        onCompleted?()
                    }
                )
            }
        )
    }
}
