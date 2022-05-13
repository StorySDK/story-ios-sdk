//
//  TextView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

class TextView: UIView {
    private var data: WidgetData!
    private var textWidget: TextWidget!
    
    private var labelRect = CGRect.zero
    
    private lazy var label: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .clear
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    convenience init(frame: CGRect, data: WidgetData, textWidget: TextWidget) {
        self.init(frame: frame)
        self.data = data
        self.textWidget = textWidget
        self.transform = CGAffineTransform.identity.rotated(by: data.position.rotate * .pi / 180)

        labelRect = CGRect(origin: CGPoint.zero, size: CGSize(width: frame.width - 16, height: frame.height - 16))
        prepareUI()
    }
    
    private func prepareUI() {
        clipsToBounds = true
        layer.cornerRadius = 8 * xScaleFactor
        layer.shadowColor = black.withAlphaComponent(0.15).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4
        backgroundColor = .clear

        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            imageView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
        ])
        
        if let image_url = self.data.content.widgetImage, let url = URL(string: image_url) {
            imageView.load(url: url)
        }

        
        setNeedsLayout()
    }
}
