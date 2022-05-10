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
//        if textWidget.withFill {
//            switch textWidget.backgroundColor {
//            case .color(let value):
//                if value.value == "purple" {
//                    let colors = [purpleStart.withAlphaComponent(CGFloat(textWidget.widgetOpacity)), purpleFinish.withAlphaComponent(CGFloat(textWidget.widgetOpacity))]
//                    let points = [CGPoint(x: 0.02, y: 0), CGPoint(x: 0.96, y: 0)]
//                    let l = Utils.getGradient(frame: bounds, colors: colors, points: points)
//                    l.cornerRadius = 8
//                    layer.insertSublayer(l, at: 0)
//                }
//                else {
//                    backgroundColor = Utils.getColor(value.value).withAlphaComponent(CGFloat(textWidget.widgetOpacity))
//                }
//            case .gradient(let value):
//                if value.type == "gradient", value.value.count > 1 {
//                    let startColor = Utils.getColor(value.value[0]).withAlphaComponent(CGFloat(textWidget.widgetOpacity))
//                    let finishColor = Utils.getColor(value.value[1]).withAlphaComponent(CGFloat(textWidget.widgetOpacity))
//                    
//                    let l = Utils.getGradient(frame: bounds, colors: [startColor, finishColor], points: [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 1)])
//                    l.cornerRadius = 8
//                    layer.insertSublayer(l, at: 0)
//                }
//            case .null(_):
//                break
//            }
//        }

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

//        imageView.image = UIImage(
//        addSubview(label)
//        NSLayoutConstraint.activate([
//            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
//            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
//            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
//            label.topAnchor.constraint(equalTo: topAnchor, constant: 8)
//        ])
//        let font = Utils.getFont(fontFamily: textWidget.fontFamily, fontSize: CGFloat(textWidget.fontSize) * xScaleFactor, fontParams: textWidget.fontParams)
//        label.font = font
//
//        label.textAlignment = Utils.getTextAlignment(textWidget.align)
//        label.text = textWidget.text
//        label.numberOfLines = 0
//        label.textColor = .white
//
        setNeedsLayout()
//
//        switch textWidget.color {
//        case .color(let value):
//            if value.value == "purple" {
//                let colors = [purpleStart.withAlphaComponent(CGFloat(textWidget.opacity)), purpleFinish.withAlphaComponent(CGFloat(textWidget.opacity))]
//                let points = [CGPoint(x: 0.02, y: 0), CGPoint(x: 0.96, y: 0)]
//                let l = Utils.getGradient(frame: bounds, colors: colors, points: points)
//                label.textColor = Utils.getLabelGradientColor(bounds: labelRect, gradientLayer: l)
//            }
//            else {
//                label.textColor = Utils.getColor(value.value).withAlphaComponent(CGFloat(textWidget.opacity))
//            }
//        case .gradient(let value):
//            if value.type == "gradient", value.value.count > 1 {
//                let startColor = Utils.getColor(value.value[0]).withAlphaComponent(CGFloat(textWidget.opacity))
//                let finishColor = Utils.getColor(value.value[1]).withAlphaComponent(CGFloat(textWidget.opacity))
//
//                let l = Utils.getGradient(frame: bounds, colors: [startColor, finishColor], points: [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 1)])
//                label.textColor = Utils.getLabelGradientColor(bounds: labelRect, gradientLayer: l)
//            }
//        case .null(_):
//            label.textColor = .white
//        }
    }
}
