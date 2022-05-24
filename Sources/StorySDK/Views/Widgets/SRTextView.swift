//
//  SRTextView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

class SRTextView: SRImageWidgetView {
    private let textWidget: TextWidget
    
    private lazy var label: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    init(data: SRWidget, textWidget: TextWidget, imageUrl: URL?, loader: SRImageLoader) {
        self.textWidget = textWidget
        super.init(data: data, url: imageUrl, loader: loader)
    }
    
    override func setupContentLayer(_ layer: CALayer) {
        layer.masksToBounds = true
        layer.cornerRadius = 8 * xScaleFactor
        layer.shadowColor = black.withAlphaComponent(0.15).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4
    }
}
