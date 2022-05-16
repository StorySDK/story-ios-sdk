//
//  SRCollectionCell.swift
//  
//
//  Created by Aleksei Cherepanov on 13.05.2022.
//

import UIKit
import Combine

class SRCollectionCell: UICollectionViewCell, SRStoryCollectionCell {
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }
    /// To cancel async opeation of image downloading
    var cancelable: Cancellable? {
        didSet { oldValue?.cancel() }
    }
    
    var isNew: Bool = false
    
    private var style: SRCollectionCellStyle = .init()
    private let imageView: UIImageView = {
        let v = UIImageView(frame: .zero)
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.isUserInteractionEnabled = false
        v.layer.borderWidth = 2
        return v
    }()
    private var borderLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.startPoint = CGPoint(x: 0.0, y: 0.5)
        l.endPoint = CGPoint(x: 1.0, y: 0.5)
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
        borderLayer.colors = style.normalBorderColors.map(\.cgColor)
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
        borderLayer.frame = .init(
            x: (bounds.width - imageSize.width) / 2,
            y: 0,
            width: imageSize.width,
            height: imageSize.height
        )
        borderLayer.cornerRadius = imageSize.height * style.corderRadius
        let inset = imageView.layer.borderWidth
        imageView.frame = borderLayer.frame.insetBy(dx: inset, dy: inset)
        imageView.layer.cornerRadius = imageView.frame.height * style.corderRadius
        
        // let titleRect: CGRect
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
        updateBorder(isNew ? style.newBorderColors : style.normalBorderColors)
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
        updateBorder(isNew ? style.newBorderColors : style.normalBorderColors)
        
        setNeedsLayout()
    }
    
    func updateBorder(_ colors: [UIColor]) {
        if colors.count == 1 {
            borderLayer.colors = [colors[0], colors[0]].map(\.cgColor)
        } else {
            borderLayer.colors = colors.map(\.cgColor)
        }
    }
}
