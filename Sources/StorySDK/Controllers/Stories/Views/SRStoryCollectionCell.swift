//
//  SRStoryCollectionCell.swift
//  
//
//  Created by Aleksei Cherepanov on 19.05.2022.
//

import UIKit
import Combine

class SRStoryCollectionCell: UICollectionViewCell, SRStoryCell {
    var backgroundColors: [UIColor]? {
        didSet {
            if let colors = backgroundColors, colors.count > 1 {
                backgroundLayer.colors = colors.map(\.cgColor)
                backgroundLayer.isHidden = false
            } else {
                backgroundLayer.isHidden = true
            }
        }
    }
    var backgroundImage: UIImage? {
        get { backgroundImageView.image }
        set {
            backgroundImageView.image = newValue
            backgroundImageView.isHidden = newValue == nil
        }
    }
    var needShowTitle: Bool {
        get { canvasView.needShowTitle }
        set { canvasView.needShowTitle = newValue }
    }
    var cancellables = [Cancellable]()
    
    private let backgroundLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.startPoint = CGPoint(x: 0.5, y: 0.0)
        l.endPoint = CGPoint(x: 0.5, y: 1.0)
        return l
    }()
    private let backgroundImageView: UIImageView = {
        let v = UIImageView(frame: .zero)
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.isUserInteractionEnabled = false
        v.isUserInteractionEnabled = false
        return v
    }()
    private let canvasView = SRStoryCanvasView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.forEach { $0.cancel() }
        cancellables = []
        backgroundColors = nil
        backgroundImage = nil
        canvasView.cleanCanvas()
    }
    
    private func setupView() {
        contentView.layer.addSublayer(backgroundLayer)
        backgroundView = backgroundImageView
        contentView.addSubview(canvasView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.frame = bounds
        canvasView.frame = bounds
    }
    
    func layoutCanvas() {
        canvasView.setNeedsLayout()
    }

    func appendWidget(_ widget: SRWidgetView, position: CGRect) {
        canvasView.appendWidget(widget, position: position)
    }
    
    func presentParticles() {
        let v = ConfettiView(frame: bounds)
        contentView.addSubview(v)
        v.startConfetti()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak v] in
            v?.stopConfetti()
            v?.removeFromSuperview()
        }
    }
}
