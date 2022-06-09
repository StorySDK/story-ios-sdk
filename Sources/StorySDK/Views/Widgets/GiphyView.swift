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
    let loader: SRImageLoader
    
    private let indicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .large)
        aiv.tintColor = .lightGray
        return aiv
    }()
    private let imageView = UIImageView(frame: .zero)
    
    private var loadTask: Cancellable? {
        didSet { oldValue?.cancel() }
    }
    
    init(data: SRWidget, giphyWidget: SRGiphyWidget, loader: SRImageLoader) {
        self.giphyWidget = giphyWidget
        self.loader = loader
        super.init(data: data)
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
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        loadTask = nil
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        load(loader)
    }
    
    private func load(_ loader: SRImageLoader) {
        startLoading()
        let size = CGSize(width: data.position.realWidth, height: data.position.realHeight)
        loadTask = loader.loadGif(giphyWidget.gif, size: size) { [weak self] result in
            defer { self?.stopLoading() }
            guard case .success(let image) = result else { return }
            self?.imageView.animationImages = image.images
            self?.imageView.animationDuration = image.duration
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

