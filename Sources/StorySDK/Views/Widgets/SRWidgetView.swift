//
//  SRWidgetView.swift
//  
//
//  Created by Aleksei Cherepanov on 23.05.2022.
//

import Combine
#if os(macOS)
    import Cocoa

    public class SRWidgetView: StoryView {
        let data: SRWidget
        
        init(data: SRWidget) {
            self.data = data
            super.init(frame: .zero)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func loadData(_ completion: @escaping () -> Void) -> Cancellable? {
            completion()
            return nil
        }
        
        func setupWidget(reaction: String) {}
    }
#elseif os(iOS)
    import UIKit

    public class SRWidgetView: StoryView {
        let contentView: UIView = .init(frame: .zero)
        let data: SRWidget
        var widgetScale: CGFloat {
            data.positionLimits.minWidth.map { data.position.realWidth / $0 } ?? 1.0
        }
        
        var loaded: Bool = false
        
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
        
        func loadData(_ completion: @escaping () -> Void) -> Cancellable? {
            completion()
            return nil
        }
        
        func setupView() {
            let angle = data.position.rotate * .pi / 180
            transform = CGAffineTransform.identity.rotated(by: angle)
            backgroundColor = .clear
            setupContentLayer(contentView.layer)
        }
        
        func setupContentLayer(_ layer: CALayer) {}
        
        func setupWidget(reaction: String) {}
        
        public override func sizeThatFits(_ size: CGSize) -> CGSize {
            return size
        }
        
        public override func layoutSubviews() {
            super.layoutSubviews()
            contentView.frame = bounds
        }
    }
#endif
