//
//  SRImageWidgetView.swift
//  
//
//  Created by Aleksei Cherepanov on 23.05.2022.
//

import UIKit
import Combine

public class SRImageWidgetView: SRInteractiveWidgetView {
    let imageView: UIImageView = {
        let v = UIImageView(frame: .zero)
        v.contentMode = .scaleAspectFit
        v.isHidden = true
        v.isUserInteractionEnabled = false
        return v
    }()
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
        addSubviews()
    }
    
    override func addSubviews() {
        super.addSubviews()
        [imageView].forEach(addSubview)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        updateImage(bounds.size, completion: {}).map { loadingTask = $0 }
    }
    
    override func loadData(_ completion: @escaping () -> Void) -> Cancellable? {
        let size = CGSize(width: data.position.realWidth, height: data.position.realHeight)
        return updateImage(size, completion: completion)
    }
    
    private var oldSize = CGSize.zero
    private func updateImage(_ size: CGSize, completion: @escaping () -> Void) -> Cancellable? {
        guard let url = url, let loader = loader else { return nil }
        guard abs(size.width - oldSize.width) > .ulpOfOne,
              abs(size.height - oldSize.height) > .ulpOfOne else { return nil }
        oldSize = size
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)
        return loader.load(url, size: targetSize) { [weak self, logger] result in
            defer { completion() }
            switch result {
            case .success(let image):
                self?.contentView.isHidden = true
                self?.imageView.isHidden = false
                self?.imageView.image = image
            case .failure(let error):
                self?.contentView.isHidden = false
                self?.imageView.isHidden = true
                logger.error(error.localizedDescription, logger: .widgets)
            }
        }
    }
}
