//
//  SRStoryCanvasView.swift
//  
//
//  Created by Aleksei Cherepanov on 19.05.2022.
//

import UIKit

struct WidgetLayout {
    var size: CGSize
    var position: CGPoint
}

final class SRStoryCanvasView: UIView {
    private let containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        return v
    }()
    private var topOffset: NSLayoutConstraint!
    private var layoutRects: [SRWidgetView: CGRect] = [:]
    
    var keyboardHeight: CGFloat = 0
    var needShowTitle: Bool = false {
        didSet { topOffset.constant = needShowTitle ? 64 : 0 }
    }
    
    init(needShowTitle: Bool = false) {
        self.needShowTitle = needShowTitle
        super.init(frame: .zero)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func appendWidget(_ widget: SRWidgetView, position: CGRect) {
        containerView.addSubview(widget)
        layoutRects[widget] = position
    }
    
    func cleanCanvas() {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        layoutRects = [:]
    }
    
    func startConfetti() {
        let v = ConfettiView(frame: bounds)
        addSubview(v)
        v.startConfetti()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            v.stopConfetti()
            v.removeFromSuperview()
        }
    }
    
    private func setupLayout() {
        addSubview(containerView)
        topOffset = containerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
        NSLayoutConstraint.activate([
            topOffset,
            containerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            containerView.rightAnchor.constraint(equalTo: rightAnchor),
            containerView.leftAnchor.constraint(equalTo: leftAnchor),
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = containerView.bounds
        for (view, rect) in layoutRects {
            let transform = view.transform
            view.transform = .identity
            var size = CGSize(
                width: frame.width * rect.width,
                height: frame.width * rect.height
            )
            size = view.sizeThatFits(size)
            let origin = CGPoint(
                x: frame.width * rect.origin.x,
                y: frame.height * rect.origin.y
            )
            view.frame = .init(origin: origin, size: size)
            view.transform = transform
        }
    }
}
