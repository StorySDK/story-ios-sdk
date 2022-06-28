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
    var cancellables = Set<AnyCancellable>()
    var isLoading: Bool = false {
        didSet { isLoading ? loadingView.startLoading() : loadingView.stopLoading() }
    }
    
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
    private let loadingView = LoadingBluredView()
    
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
        cancellables = .init()
        backgroundColors = nil
        backgroundImage = nil
        canvasView.cleanCanvas()
        isLoading = false
    }
    
    private func setupView() {
        contentView.layer.addSublayer(backgroundLayer)
        backgroundView = backgroundImageView
        [canvasView, loadingView].forEach(contentView.addSubview)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.frame = bounds
        canvasView.frame = bounds
        loadingView.frame = bounds
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

private final class LoadingBluredView: UIView {
    private let blurView: UIVisualEffectView = .init(effect: nil)
    private let loadingIndicator: UIActivityIndicatorView = .init(style: .large)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [blurView, loadingIndicator].forEach(addSubview)
        isHidden = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurView.frame = bounds
        loadingIndicator.center = blurView.center
    }
    
    func startLoading() {
        isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            let isLoading = self?.loadingIndicator.isAnimating ?? false
            guard isLoading else { return }
            UIView.animate(
                withDuration: .animationsDuration,
                delay: 0,
                options: .curveLinear,
                animations: { self?.blurView.effect = UIBlurEffect(style: .light) }
            )
        }
        loadingIndicator.startAnimating()
    }
    
    func stopLoading() {
        UIView.animate(
            withDuration: .animationsDuration,
            delay: 0,
            options: .curveLinear,
            animations: { [weak blurView] in blurView?.effect = nil },
            completion: { [weak self] _ in self?.isHidden = true }
        )
        loadingIndicator.stopAnimating()
    }
}
