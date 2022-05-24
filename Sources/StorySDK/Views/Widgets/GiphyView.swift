//
//  GiphyView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit
import Combine

class GiphyView: SRWidgetView {
    let giphyWidget: GiphyWidget
    
    private let indicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .large)
        aiv.tintColor = .lightGray
        return aiv
    }()
    private let imageView: UIImageView = {
        let v = UIImageView(frame: .zero)
        return v
    }()
    
    private var loadTask: Cancellable? {
        didSet { oldValue?.cancel() }
    }
    
    init(data: SRWidget, giphyWidget: GiphyWidget, loader: SRImageLoader) {
        self.giphyWidget = giphyWidget
        super.init(data: data)
        load(loader)
    }
    
    override func addSubviews() {
        [indicator, imageView].forEach(contentView.addSubview)
    }
    
    override func setupView() {
        super.setupView()
        clipsToBounds = true
        layer.cornerRadius = giphyWidget.borderRadius * xScaleFactor
        alpha = giphyWidget.widgetOpacity / 100
    }
    
    private func load(_ loader: SRImageLoader) {
        startLoading()
        loadTask = loader.loadGif(giphyWidget.gif, size: frame.size) { [weak self] result in
            defer { self?.stopLoading() }
            guard case .success((let images, let duration)) = result else { return }
            self?.imageView.animationImages = images
            self?.imageView.animationDuration = duration
            self?.imageView.startAnimating()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        indicator.frame = bounds
        imageView.frame = bounds
    }
    
    func startLoading() {
        indicator.isHidden = false
        indicator.startAnimating()
    }
    
    func stopLoading() {
        indicator.stopAnimating()
        indicator.isHidden = true
    }
}

