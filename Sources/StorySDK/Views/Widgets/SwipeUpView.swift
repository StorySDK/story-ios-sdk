//
//  SwipeUpView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

class SwipeUpView: UIView {
    private var story: Story!
    private var data: WidgetData!
    private var swipeUpWidget: SwipeUpWidget!
    
    private lazy var imgView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .clear
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()

    private var labelRect = CGRect.zero

//    private lazy var label: UILabel = {
//        let l = UILabel()
//        l.translatesAutoresizingMaskIntoConstraints = false
//
//        return l
//    }()
//
//    private lazy var imageView: UIImageView = {
//        let iv = UIImageView()
//        iv.translatesAutoresizingMaskIntoConstraints = false
//        iv.contentMode = .scaleAspectFit
//
//        return iv
//    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(frame: CGRect, story: Story, data: WidgetData, swipeUpWidget: SwipeUpWidget) {
        self.init(frame: frame)
        self.story = story
        self.data = data
        self.swipeUpWidget = swipeUpWidget
        self.transform = CGAffineTransform.identity.rotated(by: data.position.rotate * .pi / 180)

        labelRect = CGRect(origin: CGPoint.zero, size: CGSize(width: frame.width - 4, height: 16))
        prepareUI()
    }
    
    private func prepareUI() {
        backgroundColor = .clear
        alpha = swipeUpWidget.opacity / 100
        
//        addSubview(label)
//        NSLayoutConstraint.activate([
//            label.bottomAnchor.constraint(equalTo: bottomAnchor),
//            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 2),
//            label.rightAnchor.constraint(equalTo: rightAnchor, constant: 2)
//        ])
//        label.textAlignment = .center
//        label.numberOfLines = 0
//        label.text = swipeUpWidget.text
//        label.font = Utils.getFont(fontFamily: swipeUpWidget.fontFamily, fontSize: swipeUpWidget.fontSize, fontParams: swipeUpWidget.fontParams)
//
//        var color = UIColor.white
//        var gradinetColors = [UIColor]()
//        switch swipeUpWidget.color {
//        case .color(let value):
//            if value.value == "purple" {
//                let colors = [purpleStart.withAlphaComponent(CGFloat(swipeUpWidget.opacity)), purpleFinish.withAlphaComponent(CGFloat(swipeUpWidget.opacity))]
//                let points = [CGPoint(x: 0.02, y: 0), CGPoint(x: 0.96, y: 0)]
//                let l = Utils.getGradient(frame: labelRect, colors: colors, points: points)
//                if let c = Utils.getLabelGradientColor(bounds: labelRect, gradientLayer: l) {
//                    color = c
//                }
//                label.textColor = color
//            }
//            else {
//                color = Utils.getColor(value.value).withAlphaComponent(CGFloat(swipeUpWidget.opacity))
//            }
//        case .gradient(let value):
//            if value.type == "gradient", value.value.count > 1 {
//                let startColor = Utils.getColor(value.value[0]).withAlphaComponent(CGFloat(swipeUpWidget.opacity))
//                let finishColor = Utils.getColor(value.value[1]).withAlphaComponent(CGFloat(swipeUpWidget.opacity))
//                gradinetColors.append(startColor)
//                gradinetColors.append(finishColor)
//                let l = Utils.getGradient(frame: labelRect, colors: [startColor, finishColor], points: [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 1)])
//                if let c = Utils.getLabelGradientColor(bounds: labelRect, gradientLayer: l) {
//                    label.textColor = c
//                }
//            }
//        case .null(_):
//            color = .white
//            label.textColor = color
//        }
//
//        addSubview(imageView)
//
//        let size = swipeUpWidget.iconSize * xScaleFactor
//        NSLayoutConstraint.activate([
//            imageView.topAnchor.constraint(equalTo: topAnchor),
//            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
//            imageView.widthAnchor.constraint(equalToConstant: size),
//            imageView.heightAnchor.constraint(equalToConstant: size)
//        ])
//        if let maskImage = UIImage(named: swipeUpWidget.icon.name, in: Bundle(for: StoriesViewController.self), compatibleWith: nil) {
//            if gradinetColors.count > 0 {
//                imageView.image = maskImage.tintedWithLinearGradientColors(colors: gradinetColors)
//            }
//            else {
//                imageView.image = maskImage.withTintColor(color)
//            }
//        }

        addSubview(imgView)
        NSLayoutConstraint.activate([
            imgView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            imgView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            imgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            imgView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
        ])
        
        if let image_url = self.data.content.widgetImage, let url = URL(string: image_url) {
            imgView.load(url: url)
        }

        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(upSwiped(_:)))
        swipeUp.direction = .up
        self.addGestureRecognizer(swipeUp)

    }
    
    @objc func upSwiped(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer, swipeGesture.direction == .up {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: sendStatisticNotificationName), object: nil, userInfo: [
                widgetTypeParam: statisticClickParam,
                groupIdParam: self.story.group_id,
                storyIdParam: self.story.id,
                widgetIdParam: self.data.id,
                widgetValueParam: self.swipeUpWidget.url,
            ])
            if let url = URL(string: self.swipeUpWidget.url) {
                UIApplication.shared.open(url)
            }
        }
    }
}
