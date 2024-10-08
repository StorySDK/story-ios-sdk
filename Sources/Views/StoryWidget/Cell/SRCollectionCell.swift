//
//  SRCollectionCell.swift
//  
//
//  Created by Aleksei Cherepanov on 13.05.2022.
//

import Combine
#if os(macOS)
    import Cocoa

    final class SRCollectionCell: NSView, SRGroupsCollectionCell {
        var cancelable: Cancellable? {
            didSet {
                oldValue?.cancel()
            }
        }
        
        var title: String?
        var image: StoryImage?
        var isPresented: Bool = false
        var skeleton: Bool = false
        
        override init(frame: NSRect) {
            super.init(frame: frame)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupStyle(_ style: SRCollectionCellStyle) {
        }
        
        func makeSkeletonCell() {
            skeleton = true
        }
    }
#elseif os(iOS)
    import UIKit

    final class SRCollectionCell: UICollectionViewCell, SRGroupsCollectionCell {
        var title: String? {
            get { titleLabel.text }
            set {
                titleLabel.text = newValue
                titleLabel.removeSkeleton()
                titleLabel.layer.opacity = 1.0
                titleLabel.layer.backgroundColor = UIColor.clear.cgColor
                titleLabel.textColor = style.isTitleInside ? .white : .label
                
                borderLayer.isHidden = false
                
                setNeedsLayout()
            }
        }
        var image: UIImage? {
            get { imageView.image }
            set {
                imageView.image = newValue
                imageView.removeSkeleton()
                imageView.layer.opacity = 1.0
            }
        }
        /// To cancel async operation of image downloading
        var cancelable: Cancellable? {
            didSet {
                oldValue?.cancel()
            }
        }
        
        var isPresented: Bool = false
        var skeleton: Bool = false
        
        private var style: SRCollectionCellStyle = .init()
        private let imageView: UIImageView = {
            let v = UIImageView(frame: .zero)
            v.contentMode = .scaleAspectFill
            v.clipsToBounds = true
            v.isUserInteractionEnabled = false
            v.layer.borderWidth = 2
            return v
        }()
        private let borderLayer: CAGradientLayer = {
            let l = CAGradientLayer()
            l.startPoint = CGPoint(x: 0.0, y: 0.5)
            l.endPoint = CGPoint(x: 1.0, y: 0.5)
            l.isHidden = true
            
            return l
        }()
        private let titleLabel = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.layer.addSublayer(borderLayer)
            [imageView, titleLabel].forEach(contentView.addSubview)
            setupStyle(style)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            updateBorder(style.normalBorderColors)
            title = nil
            image = nil
            cancelable = nil
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            var imageSize: CGSize
            if style.isTitleInside {
                imageSize = bounds.size
            } else {
                imageSize = .init(width: 64, height: 64)
            }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            borderLayer.frame = .init(
                x: (bounds.width - imageSize.width) / 2,
                y: 0,
                width: imageSize.width + imageView.layer.borderWidth * 2,
                height: imageSize.height + imageView.layer.borderWidth * 2
            )
            
            borderLayer.cornerRadius = imageSize.height * style.corderRadius
            CATransaction.commit()
            
            let inset = imageView.layer.borderWidth
            imageView.frame = borderLayer.frame.insetBy(dx: inset, dy: inset)
            imageView.layer.cornerRadius = imageView.frame.height * style.corderRadius
            
            if style.isTitleInside {
                let padding = inset * 3
                let titleRect = imageView.frame.insetBy(dx: padding, dy: padding)
                let titleSize = titleLabel.sizeThatFits(titleRect.size)
                titleLabel.frame = .init(
                    x: titleRect.minX,
                    y: titleRect.maxY - titleSize.height,
                    width: titleRect.width,
                    height: titleSize.height
                )
            } else {
                let height = bounds.height - borderLayer.frame.height - inset
                let titleRect = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
                titleLabel.frame = titleRect
            }
            
        }
        
        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            imageView.layer.borderColor = style.backgroundColor.cgColor
            updateBorder(isPresented ? style.normalBorderColors : style.newBorderColors)
        }
        
        func setupStyle(_ style: SRCollectionCellStyle) {
            self.style = style
            if style.isTitleInside {
                titleLabel.numberOfLines = 0
                titleLabel.textAlignment = .left
                titleLabel.textColor = .white
            } else {
                titleLabel.numberOfLines = 1
                titleLabel.textAlignment = .center
                titleLabel.textColor = .label
            }
            titleLabel.font = style.font
            
            imageView.layer.borderColor = style.backgroundColor.cgColor
            updateBorder(isPresented ? style.normalBorderColors : style.newBorderColors)
            
            setNeedsLayout()
        }
        
        func updateBorder(_ colors: [UIColor]) {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            if colors.count == 1 {
                borderLayer.colors = [colors[0], colors[0]].map(\.cgColor)
            } else {
                borderLayer.colors = colors.map(\.cgColor)
            }
            CATransaction.commit()
        }
        
        func makeSkeletonCell() {
            skeleton = true
            
            contentView.subviews.forEach { $0.makeSkeleton() }
            borderLayer.isHidden = true
        }
    }
#endif
