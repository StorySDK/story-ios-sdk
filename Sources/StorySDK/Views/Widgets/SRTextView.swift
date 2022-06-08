//
//  SRTextView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

class SRTextView: SRImageWidgetView {
    private let textWidget: SRTextWidget
    
    private lazy var label: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    init(story: SRStory, data: SRWidget, textWidget: SRTextWidget, imageUrl: URL?, loader: SRImageLoader) {
        self.textWidget = textWidget
        super.init(story: story, data: data, url: imageUrl, loader: loader)
    }
    
    override func setupContentLayer(_ layer: CALayer) {
        layer.masksToBounds = true
        layer.cornerRadius = 8 * widgetScale
        layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4
    }
}
