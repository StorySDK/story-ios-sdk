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
    weak var loader: SRImageLoader?
    private var loadingTask: Cancellable? {
        didSet { oldValue?.cancel() }
    }
    
    init(story: SRStory, data: SRWidget, url: URL?, loader: SRImageLoader) {
        self.url = url
        self.loader = loader
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
        updateImage()
    }
    
    private var oldSize = CGSize.zero
    private func updateImage() {
        guard let url = url, let loader = loader else { return }
        let size = bounds.size
        guard abs(size.width - oldSize.width) > .ulpOfOne,
              abs(size.height - oldSize.height) > .ulpOfOne else { return }
        oldSize = size
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)
        loadingTask = loader.load(url, size: targetSize) { [weak self] result in
            switch result {
            case .success(let image):
                self?.contentView.isHidden = true
                self?.imageView.isHidden = false
                self?.imageView.image = image
            case .failure(let error):
                self?.contentView.isHidden = false
                self?.imageView.isHidden = true
                logError(error.localizedDescription, logger: .widgets)
            }
        }
    }
}
