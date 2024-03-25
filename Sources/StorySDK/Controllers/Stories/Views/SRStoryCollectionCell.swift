//
//  SRStoryCollectionCell.swift
//  
//
//  Created by Aleksei Cherepanov on 19.05.2022.
//

import Combine

#if os(macOS)
    import Cocoa

    class SRStoryCollectionCell: NSView {
        
        override init(frame: NSRect) {
            super.init(frame: frame)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
#elseif os(iOS)
    import UIKit
    import AVFoundation


protocol SRSizeDelegate: AnyObject {
    
    func getDefaultStorySize() -> CGSize
}

class SRStoryCollectionCell: UICollectionViewCell, SRStoryCell {
        internal static let supportedVideoExt = "mp4"
        
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
        
        var backgroundVideo: URL? {
            didSet {
                if oldValue == backgroundVideo {
                    return
                }
                
                if let remoteUrl = backgroundVideo {
                    var mp4LocalUrl: URL?
                    if let shaHash = remoteUrl.absoluteString.data(using: .utf8)?.sha256().hex() {
                        if let path = Bundle.main.url(forResource: shaHash,
                                                     withExtension: SRStoryCollectionCell.supportedVideoExt) {
                            mp4LocalUrl = path
                        } else {
                            do {
                                let fileManager = FileManager.default
                                let cacheDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                                let fileName = shaHash + "." + SRStoryCollectionCell.supportedVideoExt
                                let tempUrl = cacheDirectory.appendingPathComponent(fileName)
                                
                                if fileManager.fileExists(atPath: tempUrl.absoluteString) {
                                    mp4LocalUrl = tempUrl
                                }
                            } catch {
                                
                            }
                        }
                    }
                    
                    let videoUrl = mp4LocalUrl ?? remoteUrl
                    player = AVPlayer(url: videoUrl)
                    backgroundVideoLayer.player = player
                    player?.play()
                    
                    if let thePlayer = player {
                        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: thePlayer.currentItem, queue: .main) { _ in
                            thePlayer.seek(to: CMTime.zero)
                            thePlayer.play()
                        }
                    }
                }
            }
        }

        var needShowTitle: Bool {
            get { canvasView.needShowTitle }
            set { canvasView.needShowTitle = newValue }
        }
    
        var defaultStorySize: CGSize?
    
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
        
        private var player: AVPlayer?
        private let backgroundVideoLayer: AVPlayerLayer = {
            let l = AVPlayerLayer(player: nil)
            l.videoGravity = .resizeAspectFill
            return l
        }()
        
        private lazy var canvasView: SRStoryCanvasView = {
            let v = SRStoryCanvasView()
            v.delegate = self
            return v
        }()
    
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
            isLoading = false
        }
        
        private func setupView() {
            contentView.layer.addSublayer(backgroundLayer)
            contentView.layer.addSublayer(backgroundVideoLayer)
            
            backgroundView = backgroundImageView
            [canvasView, loadingView].forEach(contentView.addSubview)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            backgroundLayer.frame = bounds
            backgroundVideoLayer.frame = bounds
            canvasView.frame = bounds
            loadingView.frame = bounds
        }
        
        func layoutCanvas() {
            canvasView.setNeedsLayout()
        }

        func appendWidget(_ widget: SRWidgetView, position: CGRect) {
            canvasView.appendWidget(widget, position: position)
        }
        
        func widgets() -> [SRWidgetView]? {
            canvasView.widgets()
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
                    withDuration: SRConstants.animationsDuration,
                    delay: 0,
                    options: .curveLinear,
                    animations: { self?.blurView.effect = UIBlurEffect(style: .light) }
                )
            }
            loadingIndicator.startAnimating()
        }
        
        func stopLoading() {
            UIView.animate(
                withDuration: SRConstants.animationsDuration,
                delay: 0,
                options: .curveLinear,
                animations: { [weak blurView] in blurView?.effect = nil },
                completion: { [weak self] _ in self?.isHidden = true }
            )
            loadingIndicator.stopAnimating()
        }
    }

extension SRStoryCollectionCell: SRSizeDelegate {
    func getDefaultStorySize() -> CGSize {
        defaultStorySize ?? .smallStory
    }
}
#endif
