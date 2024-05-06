//
//  RateControl.swift
//  StorySDK
//
//  Created by Igor Efremov on 02.06.2023.
//

#if os(macOS)
    import Cocoa

    final class RateControl: StoryButton {
        
        public init(frame: NSRect, starsNumber: Int = 5) {
            super.init(frame: frame)
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
    }
#elseif os(iOS)
    import UIKit

    final class RateControl: StoryButton {
        private var starsNumber: Int = 5
        private var selectedStars: Int = 0 {
            didSet {
                displaySelectedStars()
            }
        }
        
        lazy private var starsView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 5
            stackView.isUserInteractionEnabled = false
            stackView.backgroundColor = .clear
            return stackView
        }()
        
        public init(frame: CGRect, starsNumber: Int = 5) {
            self.starsNumber = starsNumber
            
            super.init(frame: frame)
            prepareUI()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            prepareUI()
        }
        
        private func displaySelectedStars() {
            let config = UIImage.SymbolConfiguration(weight: .thin)
            
            for i in 0..<starsNumber {
                let starImageName: String = i < selectedStars ? "star.fill" : "star"
                let starImage = UIImage(systemName: starImageName, withConfiguration: config)
                
                if i < starsView.arrangedSubviews.count,
                   let imageView = starsView.arrangedSubviews[i] as? UIImageView {
                    imageView.image = starImage
                } else {
                    let imageView = UIImageView(image: starImage)
                    imageView.contentMode = .scaleAspectFit
                    starsView.addArrangedSubview(imageView)
                }
            }
            
            sendActions(for: .valueChanged)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            starsView.frame = self.bounds
        }
        
        private func prepareUI() {
            addSubview(starsView)
            let config = UIImage.SymbolConfiguration(weight: .thin)
            let starImageName: String = "star"
            let starImage = UIImage(systemName: starImageName, withConfiguration: config)
            
            for _ in 0..<starsNumber {
                let imageView = UIImageView(image: starImage)
                imageView.tintColor = .white
                imageView.contentMode = .scaleAspectFit
                
                starsView.addArrangedSubview(imageView)
            }
        }
        
        override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
            let x = touch.location(in: self).x
            changeSelectedStars(offset: x)
            
            return true
        }
        
        public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
            var x = touch.location(in: self).x
            x = max(0, x)
            x = min(x, bounds.maxX)
            changeSelectedStars(offset: x)
            
            return true
        }
        
        private func changeSelectedStars(offset x: CGFloat) {
            let value = Int(ceil(x / bounds.width * CGFloat(starsNumber)))
            if value != selectedStars {
                selectedStars = value
            }
        }
    }
#endif
