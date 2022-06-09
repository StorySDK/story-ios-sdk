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
    private let gifQueue = DispatchQueue(label: "\(packageBundleId).gifQueue",
                                         qos: .userInitiated)
    
    private let indicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .large)
        aiv.tintColor = .lightGray
        return aiv
    }()
    
    private var loadTask: Cancellable? {
        didSet { oldValue?.cancel() }
    }
    
    private let options = [
        String(kCGImageSourceShouldCache): kCFBooleanFalse,
    ] as CFDictionary
    private var source: CGImageSource?
    private var currentImage: CGImage?
    private var currentIndex: Int = 0
    private var numberOfFrames: Int = 0
    private var displayLink: CADisplayLink!
    private var nextUpdate: TimeInterval = 0
    
    init(data: SRWidget, giphyWidget: SRGiphyWidget, loader: SRImageLoader) {
        self.giphyWidget = giphyWidget
        self.loader = loader
        super.init(data: data)
        displayLink = .init(target: self, selector: #selector(linkDisplay))
        displayLink.add(to: .main, forMode: .default)
        displayLink.isPaused = true
    }
    
    deinit {
        loadTask = nil
    }
    
    override func addSubviews() {
        super.addSubviews()
        [indicator].forEach(contentView.addSubview)
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
        displayLink.invalidate()
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
            guard case .success(let data) = result else { return }
            self?.loadData(data)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        indicator.frame = bounds
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let image = currentImage else { return }
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.saveGState()
        let transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: rect.height)
        ctx.concatenate(transform)
        ctx.draw(image, in: rect)
        ctx.restoreGState()
    }
    
    @objc func linkDisplay() {
        guard displayLink.timestamp > nextUpdate else { return }
        updateImage()
    }
    
    private func loadData(_ data: Data) {
        source = CGImageSourceCreateWithData(data as CFData, options)
        guard let source = source else { return }
        currentIndex = 0
        numberOfFrames = CGImageSourceGetCount(source)
        updateImage()
    }
    
    private func updateImage() {
        guard numberOfFrames > 0 else { return }
        var index = currentIndex + 1
        if index >= numberOfFrames { index = 0 }
        guard let source = source else { return }
        nextUpdate = 0
        gifQueue.async { [weak self, options] in
            guard let image = CGImageSourceCreateImageAtIndex(source, index, options) else { return }
            let duration = source.delay(for: index)
            DispatchQueue.main.async {
                guard let wSelf = self else { return }
                wSelf.currentImage = image
                wSelf.currentIndex = index
                wSelf.displayLink.isPaused = false
                wSelf.nextUpdate = wSelf.displayLink.timestamp + duration
                wSelf.setNeedsDisplay()
            }
        }
    }
    
    private func startLoading() {
        indicator.isHidden = false
        indicator.startAnimating()
    }
    
    private func stopLoading() {
        indicator.stopAnimating()
        indicator.isHidden = true
    }
}

private extension CGImageSource {
    func delay(for index: Int) -> TimeInterval {
        var delay: TimeInterval = 0.1
        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(self, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        if CFDictionaryGetValueIfPresent(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque(), gifPropertiesPointer) == false {
            return delay
        }
        
        let gifProperties: CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
        
        // Get delay time
        var delayObject = unsafeBitCast(
            CFDictionaryGetValue(
                gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()
            ),
            to: AnyObject.self
        )
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(
                CFDictionaryGetValue(
                    gifProperties,
                    Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()),
                to: AnyObject.self
            )
        }
        
        delay = delayObject as? TimeInterval ?? 0
        return delay // max(0.1, delay)
    }
}
