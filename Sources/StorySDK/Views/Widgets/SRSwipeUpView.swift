//
//  SRSwipeUpView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

protocol SRSwipeUpViewDelegate: AnyObject {
    func didSwipeUp(_ widget: SRSwipeUpView)
}

class SRSwipeUpView: SRImageWidgetView {
    let swipeUpWidget: SRSwipeUpWidget
    
    private let iconView: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "chevron.up.circle"))
        v.tintColor = .white
        v.contentMode = .scaleAspectFit
        v.isUserInteractionEnabled = false
        return v
    }()
    private let titleLabel: UILabel = {
        let v = UILabel()
        v.textAlignment = .center
        v.textColor = .white
        return v
    }()

    init(story: SRStory, data: SRWidget, swipeUpWidget: SRSwipeUpWidget, imageUrl: URL?, loader: SRImageLoader, logger: SRLogger) {
        self.swipeUpWidget = swipeUpWidget
        super.init(story: story, data: data, url: imageUrl, loader: loader, logger: logger)
    }
    
    override func addSubviews() {
        super.addSubviews()
        [iconView, titleLabel].forEach(contentView.addSubview)
    }
    
    override func setupView() {
        super.setupView()
        
        alpha = swipeUpWidget.opacity / 100
        titleLabel.text = swipeUpWidget.text
        titleLabel.font = .regular(ofSize: swipeUpWidget.fontSize)
        
        if case .color(let color) = swipeUpWidget.color {
            iconView.tintColor = color
            titleLabel.textColor = color
        }
        
        if let name = swipeUpWidget.icon.systemIconName {
            iconView.image = UIImage(systemName: name)
        }
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(upSwiped(_:)))
        swipeUp.direction = .up
        self.addGestureRecognizer(swipeUp)
    }
    
    @objc func upSwiped(_ gesture: UISwipeGestureRecognizer) {
        guard gesture.direction == .up else { return }
        delegate?.didSwipeUp(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let scale = widgetScale
        titleLabel.font = .regular(ofSize: swipeUpWidget.fontSize * scale)
        iconView.frame = .init(
            x: 0, y: 0,
            width: bounds.width,
            height: swipeUpWidget.iconSize * scale)
        let y = iconView.frame.maxY + 6 * scale
        titleLabel.frame = .init(
            x: 0, y: y,
            width: bounds.width,
            height: max(0, bounds.height - y))
    }
}
