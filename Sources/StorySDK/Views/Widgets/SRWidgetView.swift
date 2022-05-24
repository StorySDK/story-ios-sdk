//
//  SRWidgetView.swift
//  
//
//  Created by Aleksei Cherepanov on 23.05.2022.
//

import UIKit

public class SRWidgetView: UIView {
    let contentView: UIView = .init(frame: .zero)
    let data: SRWidget
    
    init(data: SRWidget) {
        self.data = data
        super.init(frame: .zero)
        addSubviews()
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        [contentView].forEach(addSubview)
    }
    
    func setupView() {
        let angle = data.position.rotate * .pi / 180
        transform = CGAffineTransform.identity.rotated(by: angle)
        backgroundColor = .clear
        setupContentLayer(contentView.layer)
    }
    
    func setupContentLayer(_ layer: CALayer) {}
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return size
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }
}
