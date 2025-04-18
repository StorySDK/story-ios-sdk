//
//  PlayerView.swift
//  StorySDK
//
//  Created by Ingvarr Alef on 20.05.2023.
//

#if os(macOS)
    import Cocoa

    final class PlayerView: StoryView {
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

    final class PlayerView: UIView {
        private var playerItemContext = 0
        var playerItem: AVPlayerItem?
        
        var identifier: String?
        
        var stopped: Bool = false
        var paused: Bool = false
        
        var nObserver: NSObjectProtocol?
        
        init(identifier: String) {
            self.identifier = identifier
            self.stopped = false
            super.init(frame: .zero)
            addEvents()
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func addEvents() {
            NotificationCenter.default
                .addObserver(self,
                             selector: #selector(togglePlayer),
                             name: NSNotification.Name("playerToggle"),
                             object: nil)
        }
        
        override class var layerClass: AnyClass {
            return AVPlayerLayer.self
        }
        
        var player: AVPlayer? {
            get {
                return playerLayer.player
            }
            set {
                playerLayer.player = newValue
            }
        }
        
        var playerLayer: AVPlayerLayer {
            return layer as! AVPlayerLayer
        }
        
        private func setUpAsset(with url: URL, completion: ((_ asset: AVAsset) -> Void)?) {
            let asset = AVAsset(url: url)
            asset.loadValuesAsynchronously(forKeys: ["playable"]) {
                var error: NSError? = nil
                let status = asset.statusOfValue(forKey: "playable", error: &error)
                switch status {
                case .loaded:
                    completion?(asset)
                case .failed:
                    logger.debug(".failed")
                case .cancelled:
                    logger.debug(".cancelled")
                default:
                    logger.debug("default")
                }
            }
        }
        
        private func setUpPlayerItem(with asset: AVAsset) {
            playerItem = AVPlayerItem(asset: asset)
            playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &playerItemContext)
                
            DispatchQueue.main.async { [weak self] in
                self?.player = AVPlayer(playerItem: self?.playerItem!)
            }
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            // Only handle observations for the playerItemContext
            guard context == &playerItemContext else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                return
            }
                
            if keyPath == #keyPath(AVPlayerItem.status) {
                let status: AVPlayerItem.Status
                if let statusNumber = change?[.newKey] as? NSNumber {
                    status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
                } else {
                    status = .unknown
                }
                // Switch over status value
                switch status {
                case .readyToPlay:
                    logger.debug(".readyToPlay")
                    player?.pause()
                    player?.seek(to: .zero) { [weak self] _ in
                        self?.player?.play()
                    }
                case .failed:
                    logger.debug(".failed")
                case .unknown:
                    logger.debug(".unknown")
                @unknown default:
                    logger.debug("@unknown default")
                }
            }
        }
        
        @objc func togglePlayer() {
            if !paused {
                pauseVideo()
            } else {
                restoreVideo()
            }
        }
        
        func play(with url: URL) {
            setUpAsset(with: url) { [weak self] (asset: AVAsset) in
                self?.setUpPlayerItem(with: asset)
            }
        }
        
        func stopVideo() {
            stopped = true
            player?.pause()
        }
        
        func pauseVideo() {
            paused = true
            player?.pause()
        }
        
        func restoreVideo() {
            paused = false
            player?.play()
        }
        
        func restartVideo() {
            stopped = false
            loopVideo()
        }
        
        func loopVideo() {
            logger.debug("loopVideo")
            NotificationCenter.default.removeObserver(nObserver)
            nObserver = nil
            
            nObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player?.currentItem,
                queue: .main
            ) { [weak self] notification in
                if self?.stopped == true {
                    logger.debug("current player is stopped")
                    return
                }

                self?.player?.pause()
                self?.player?.seek(to: .zero)
                self?.player?.play()
            }
        }
        
        deinit {
            playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
            NotificationCenter.default.removeObserver(nObserver)
            
            logger.debug("deinit of PlayerView")
        }
    }
#endif
