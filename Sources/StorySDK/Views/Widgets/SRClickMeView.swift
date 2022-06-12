//
//  SRClickMeView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

protocol SRClickMeViewDelegate: AnyObject {
    func didClickedButton(_ widget: SRClickMeView)
}

class SRClickMeView: SRImageWidgetView {
    let clickMeWidget: SRClickMeWidget
    
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
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(meClicked(_:)))
        addGestureRecognizer(tapgesture)
    }
    
    @objc private func meClicked(_ sender: Any) {
        animateView()
    }
    
    private func animateView() {
        delegate?.didClickedButton(self)
        UIView.animate(
            withDuration: .animationsDuration,
            animations: { [weak self] in
                self?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            },
            completion: { [weak self] _ in
                UIView.animate(
                    withDuration: .animationsDuration,
                    animations: { self?.transform = .identity }
                )
            }
        )
    }
}
