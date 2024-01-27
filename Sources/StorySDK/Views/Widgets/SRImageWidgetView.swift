//
//  SRImageWidgetView.swift
//  
//
//  Created by Aleksei Cherepanov on 23.05.2022.
//

import Combine
#if os(macOS)
    import Cocoa

    public class SRImageWidgetView: SRInteractiveWidgetView {
        let url: URL?
        
        init(story: SRStory, data: SRWidget, url: URL?, loader: SRImageLoader, logger: SRLogger) {
            self.url = url
            super.init(story: story, data: data)
        }
    }
#elseif os(iOS)
    import UIKit
    import AVFoundation

    public class SRImageWidgetView: SRInteractiveWidgetView {
        internal static let supportedVideoExt = "mp4"
        
        let imageView: UIImageView = {
            let v = UIImageView(frame: .zero)
            v.contentMode = .scaleAspectFill
            v.isHidden = true
            v.isUserInteractionEnabled = false
            return v
        }()
        
        var playerContainerView: UIView!
        var playerView: PlayerView!
        
        let url: URL?
        let logger: SRLogger
        weak var loader: SRImageLoader?
        private var loadingTask: Cancellable? {
            didSet { oldValue?.cancel() }
        }
        
        init(story: SRStory, data: SRWidget, url: URL?, loader: SRImageLoader, logger: SRLogger) {
            self.url = url
            self.loader = loader
            self.logger = logger
            super.init(story: story, data: data)
            
            if url == nil {
                self.loaded = true
            }
            
            if StorySDK.shared.debugMode {
                backgroundColor = .magenta
            }
            
            if let vUrl = url {
                if SRImageWidgetView.supportedVideoExt == vUrl.pathExtension  {
                    var videoURL: URL = vUrl
                    
                    if let shaHash = vUrl.absoluteString.data(using: .utf8)?.sha256().hex() {
                        if let fileURL = Bundle.main.url(forResource: shaHash, withExtension: SRImageWidgetView.supportedVideoExt) {
                            videoURL = fileURL
                        }
                    }
                    
                    playVideo(url: videoURL)
                }
            }
        }
        
        deinit {
            let sdk = StorySDK.shared
            sdk.logger.debug("deinit of SRImageWidgetView")
        }
        
        public func isVideo() -> Bool {
            if let vUrl = url {
                if SRImageWidgetView.supportedVideoExt == vUrl.pathExtension {
                    return true
                }
            }
            
            return false
        }
        
        override func addSubviews() {
            super.addSubviews()
            [imageView].forEach(addSubview)
            
            if isVideo() {
                setUpPlayerContainerView()
                
                playerView = PlayerView(identifier: data.id)
                playerContainerView.addSubview(playerView)
            }
        }
          
        private func playVideo(url: URL) {
            playerView.play(with: url)
        }
        
        private func setUpPlayerContainerView() {
            playerContainerView = UIView()
            playerContainerView.backgroundColor = .clear
            
            addSubview(playerContainerView)
            
            playerContainerView.translatesAutoresizingMaskIntoConstraints = false
            playerContainerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            playerContainerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            playerContainerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
            playerContainerView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        }
        
        public override func layoutSubviews() {
            super.layoutSubviews()
            imageView.frame = bounds
            playerView?.frame = playerContainerView.bounds
            
            updateImage(bounds.size, completion: {}).map { loadingTask = $0 }
        }
        
        override func loadData(_ completion: @escaping () -> Void) -> Cancellable? {
            let size = CGSize(width: data.position.realWidth, height: data.position.realHeight)
            return updateImage(size, completion: completion)
        }
        
        private var oldSize = CGSize.zero
        private func updateImage(_ size: CGSize, completion: @escaping () -> Void) -> Cancellable? {
            guard let url = url,
                  let loader = loader,
                  abs(size.width - oldSize.width) > .ulpOfOne,
                  abs(size.height - oldSize.height) > .ulpOfOne else {
                delegate?.didWidgetLoad(self)
                
                completion()
                return nil
            }
            oldSize = size
            let scale = StoryScreen.screenScale
            let targetSize = CGSize(width: size.width * scale, height: size.height * scale)
            
            return loader.load(url, size: targetSize) { [weak self, logger] result in
                defer { completion() }
                switch result {
                case .success(let image):
                    self?.contentView.isHidden = true
                    self?.imageView.isHidden = false
                    self?.imageView.image = image
                case .failure(let error as CancellationError):
                    logger.error(error.localizedDescription, logger: .widgets)
                case .failure(let error):
                    self?.contentView.isHidden = false
                    self?.imageView.isHidden = true
                    logger.error(error.localizedDescription, logger: .widgets)
                }
                
                if let wSelf = self {
                    wSelf.delegate?.didWidgetLoad(wSelf)
                }
            }
        }
    }
#endif
