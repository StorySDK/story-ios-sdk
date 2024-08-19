//
//  SRLinkView.swift
//  StorySDK
//
//  Created by Ingvarr Alef on 18/08/2024.
//

import UIKit

class SRLinkView: SRImageWidgetView {
    let linkWidget: SRLinkWidget
    
    var bgColor = UIColor.clear
    var gradientColors: [UIColor] = []
    var gradientSetup: Bool = false
    
    private let headerLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        
        return lbl
    }()
    
    let imgView: UIImageView = {
        let v = UIImageView(frame: .zero)
        v.contentMode = .scaleAspectFit
        v.isUserInteractionEnabled = false
        v.clipsToBounds = true
        
        return v
    }()
    
    init(story: SRStory, defaultStorySize: CGSize, data: SRWidget,
         linkWidget: SRLinkWidget, imageUrl: URL?, loader: SRImageLoader, logger: SRLogger) {
        self.linkWidget = linkWidget
        super.init(story: story, defaultStorySize: defaultStorySize, data: data, url: imageUrl, loader: loader, logger: logger)
    }
    
    deinit {
        logger.debug("deinit of SRLinkView")
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
        contentView.addSubview(imgView)
        
        switch linkWidget.backgroundColor {
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
        
        imgView.image = loadImage()
        headerLabel.text = linkWidget.text
        
        var textColor = UIColor.clear
        switch linkWidget.color {
        case .color(let color, _):
            textColor = color
        default:
            break
        }
        
        headerLabel.textColor = textColor
        headerLabel.font = .improvedFont(family: linkWidget.fontFamily, ofSize: linkWidget.fontSize, weight: linkWidget.fontParams.weight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if gradientColors.count > 1 && !gradientSetup && contentView.frame.width > .ulpOfOne {
            contentView.setHorizontalGradientBackground(left: gradientColors.first ?? bgColor, right: gradientColors.last ?? bgColor)
            gradientSetup = true
        }
        
        if contentView.bounds.width > .ulpOfOne {
            contentView.layer.cornerRadius = calcCorrectRadius(contentView)
            let frame = contentView.bounds
            if let rc = headerLabel.text?.boundingRectWithSize(contentView.bounds.size,
                                                              font: headerLabel.font) {
                let fullWidth = 24.0 + 8.0 + ceil(rc.width)
                imgView.frame = CGRect(origin: CGPoint(x: (frame.width - fullWidth) / 2, y: (frame.height - 24) / 2),
                                                       size: CGSize(width: 24, height: 24) )
                headerLabel.frame = CGRect(x: (frame.width - fullWidth) / 2 + 24.0 + 8.0, y: frame.origin.y, width: ceil(rc.width), height: frame.size.height)
            }
        }
    }
    
    private func calcCorrectRadius(_ button: UIView) -> CGFloat {
        min(12, button.bounds.height / 2)
    }
    
    @objc private func onTap(_ sender: Any) {
        animateView(onCompleted: { [weak self] in
            guard let wSelf = self else { return }
            wSelf.delegate?.didTapLink(wSelf)
        })
    }
    
    func loadImage() -> UIImage? {
        guard let url = Bundle.module.url(forResource: "link-icon", withExtension: "png") else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
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

protocol SRLinkViewDelegate: AnyObject {
    func didTapLink(_ widget: SRLinkView)
}
