//
//  GiphyView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

class GiphyView: UIView {
    private var data: WidgetData!
    private var giphyWidget: GiphyWidget!
    
    private lazy var indicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .large)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.tintColor = .lightGray
        return aiv
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(frame: CGRect, data: WidgetData, giphyWidget: GiphyWidget) {
        self.init(frame: frame)
        self.data = data
        self.giphyWidget = giphyWidget
        self.transform = CGAffineTransform.identity.rotated(by: data.position.rotate * .pi / 180)

        prepareUI()
    }
    
    private func prepareUI() {
        clipsToBounds = true
        layer.cornerRadius = giphyWidget.borderRadius * xScaleFactor
        layer.shadowColor = black.withAlphaComponent(0.15).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4

        addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        indicator.isHidden = false
        indicator.startAnimating()
        
        let iv = UIImageView(frame: self.bounds)
        self.addSubview(iv)
        alpha = giphyWidget.widgetOpacity / 100
        DispatchQueue.main.async {
            let gifURL = self.giphyWidget.gif
            if let url = URL(string: gifURL) {
//                print("==== Start loading gif =================")
//                LazyImageLoader.shared.loadGifImage(url: url, size: self.frame.size, completion: { images, duration, error in
//                    DispatchQueue.main.async {
//                        self.indicator.stopAnimating()
//                        self.indicator.isHidden = true
//                    }
//                    if let error = error {
//                        print(error.localizedDescription)
//                    } else if let images = images {
//                        DispatchQueue.main.async {
//                            iv.animationImages = images
//                            iv.animationDuration = duration
//                            iv.startAnimating()
//                        }
//                    }
//                })
            }
        }
    }
}
