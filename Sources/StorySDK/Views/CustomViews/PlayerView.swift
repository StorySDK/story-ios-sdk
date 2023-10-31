//
//  PlayerView.swift
//  StorySDK
//
//  Created by Igor Efremov on 20.05.2023.
//

#if os(macOS)
    import Cocoa

    final class PlayerView: UIView {
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
        //private
        var playerItem: AVPlayerItem?
        
        var identifier: String?
        
        var stopped: Bool = false
        
        init(identifier: String) {
            self.identifier = identifier
            self.stopped = false
            super.init(frame: .zero)
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
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
                    print(".failed")
                case .cancelled:
                    print(".cancelled")
                default:
                    print("default")
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
                    print(".readyToPlay")
                    player?.play()
                case .failed:
                    print(".failed")
                case .unknown:
                    print(".unknown")
                @unknown default:
                    print("@unknown default")
                }
            }
        }
        
        func play(with url: URL) {

            
            setUpAsset(with: url) { [weak self] (asset: AVAsset) in
                self?.setUpPlayerItem(with: asset)
                self?.loopVideo()
            }
        }
        
        func stopVideo() {
            stopped = true
        }
        
        func restartVideo() {
            stopped = false
            player?.seek(to: .zero)
            player?.play()
        }
        
        func loopVideo() {//videoPlayer: AVPlayer) {
            let sdk = StorySDK.shared
            sdk.logger.debug("loopVideo")
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: player?.currentItem, queue: nil) { [weak self] notification in
            if self?.stopped == true {
                print("current player \(self?.identifier) is stopped")
                return
            }
         
              NSLog("Player \(self?.identifier) seek to zero")
              self?.player?.seek(to: .zero)
              self?.player?.play()
          }
        }
        
        deinit {
            let sdk = StorySDK.shared
            sdk.logger.debug("deinit of PlayerView")
            
            playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                      object: nil)
            //print("deinit of PlayerView")
        }
    }
#endif
