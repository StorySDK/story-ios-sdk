//
//  GiphyView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit
import Combine

class GiphyView: SRWidgetView {
    let giphyWidget: SRGiphyWidget
    
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
    
    init(data: SRWidget, giphyWidget: SRGiphyWidget, loader: SRImageLoader) {
        self.giphyWidget = giphyWidget
        super.init(data: data)
        load(loader)
    }
    
    deinit {
        loadTask = nil
    }
    
    override func addSubviews() {
        super.addSubviews()
        [indicator, imageView].forEach(contentView.addSubview)
    }
    
    override func setupView() {
        super.setupView()
        clipsToBounds = true
        layer.cornerRadius = giphyWidget.borderRadius
        alpha = giphyWidget.widgetOpacity / 100
    }
    
    private func load(_ loader: SRImageLoader) {
        startLoading()
        let size = CGSize(width: data.position.realWidth, height: data.position.realHeight)
        loadTask = loader.loadGif(giphyWidget.gif, size: size) { [weak self] result in
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

