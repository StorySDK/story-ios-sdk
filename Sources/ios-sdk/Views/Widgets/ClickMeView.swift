//
//  ClickMeView.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

class ClickMeView: UIView {
    private var story: Story!
    private var data: WidgetData!
    private var clickMeWidget: ClickMeWidget!
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .clear
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(frame: CGRect, story: Story, data: WidgetData, clickMeWidget: ClickMeWidget) {
        self.init(frame: frame)
        self.story = story
        self.data = data
        self.clickMeWidget = clickMeWidget
        self.transform = CGAffineTransform.identity.rotated(by: data.position.rotate * .pi / 180)

        prepareUI()
    }
    
    private func prepareUI() {
        clipsToBounds = true
//        layer.cornerRadius = frame.height / 2
        layer.shadowColor = black.withAlphaComponent(0.15).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4
        backgroundColor = .clear
//        switch clickMeWidget.backgroundColor {
//        case .color(let value):
//            if value.value == "purple" {
//                let colors = [purpleStart, purpleFinish]
//                let points = [CGPoint(x: 0.02, y: 0), CGPoint(x: 0.96, y: 0)]
//                let l = Utils.getGradient(frame: bounds, colors: colors, points: points)
//                l.cornerRadius = 10
//                layer.insertSublayer(l, at: 0)
//            }
//            else {
//                backgroundColor = Utils.getColor(value.value)
//            }
//        case .gradient(let value):
//            if value.type == "gradient", value.value.count > 1 {
//                let startColor = Utils.getColor(value.value[0])
//                let finishColor = Utils.getColor(value.value[1])
//
//                let l = Utils.getGradient(frame: bounds, colors: [startColor, finishColor], points: [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 1)])
//                layer.insertSublayer(l, at: 0)
//            }
//        case .null(_):
//            break
//        }
//        if clickMeWidget.hasBorder {
//            layer.borderWidth = CGFloat(clickMeWidget.borderWidth)
//            switch clickMeWidget.borderColor {
//            case .color(let value):
//                if value.value != "purple" {
//                    layer.borderColor = Utils.getColor(value.value).withAlphaComponent(CGFloat(clickMeWidget.borderOpacity / 100)).cgColor
//                }
//            default:
//                break
//            }
//        }
//
//        let sv = UIStackView()
//        sv.translatesAutoresizingMaskIntoConstraints = false
//        sv.backgroundColor = .clear
//        addSubview(sv)
//        NSLayoutConstraint.activate([
//            sv.centerXAnchor.constraint(equalTo: centerXAnchor),
//            sv.centerYAnchor.constraint(equalTo: centerYAnchor),
//            sv.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 4),
//            sv.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: -4),
//            sv.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 8),
//            sv.rightAnchor.constraint(greaterThanOrEqualTo: rightAnchor, constant: -8)
//        ])
//        sv.axis = .horizontal
//        sv.spacing = 8
//        sv.alignment = .center
//        sv.distribution = .fill
//        var color = UIColor.white
//        switch clickMeWidget.color {
//        case .color(let value):
//            if value.value != "purple" {
//                color = Utils.getColor(value.value).withAlphaComponent(CGFloat(clickMeWidget.opacity / 100))
//            }
//        default:
//            break
//        }
//
//        if clickMeWidget.hasIcon {
//            if let maskImage = UIImage(named: clickMeWidget.icon.name, in: Bundle(for: StoriesViewController.self), compatibleWith: nil) {
//                let iv = UIImageView()
//                NSLayoutConstraint.activate([
//                    iv.heightAnchor.constraint(equalToConstant: CGFloat(clickMeWidget.iconSize)),
//                    iv.widthAnchor.constraint(equalToConstant: CGFloat(clickMeWidget.iconSize))
//                ])
//                iv.image = maskImage.withTintColor(color)
//
//                sv.addArrangedSubview(iv)
//            }
//        }
//
//        let label = UILabel()
//        switch clickMeWidget.color {
//        case .color(let value):
//            if value.value != "purple" {
//                label.textColor = color
//            }
//        default:
//            break
//        }
//        label.text = clickMeWidget.text
//        let font = Utils.getFont(fontFamily: clickMeWidget.fontFamily, fontSize: clickMeWidget.fontSize, fontParams: clickMeWidget.fontParams)
//        label.font = font
//        label.numberOfLines = 0
//
//        sv.addArrangedSubview(label)

        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            imageView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        ])
        
        if let image_url = self.data.content.widgetImage, let url = URL(string: image_url) {
            imageView.load(url: url)
        }

        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(meClicked(_:)))
        addGestureRecognizer(tapgesture)
    }
    
    @objc private func meClicked(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: disableSwipeNotificanionName), object: nil)
        animateView()
    }
    
    private func animateView() {
        UIView.animate(withDuration: animationsDuration, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: {_ in
            UIView.animate(withDuration: animationsDuration, animations: {
                self.transform = CGAffineTransform.identity
            }, completion: {_ in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: sendStatisticNotificationName), object: nil, userInfo: [
                    widgetTypeParam: statisticClickParam,
                    groupIdParam: self.story.group_id,
                    storyIdParam: self.story.id,
                    widgetIdParam: self.data.id,
                    widgetValueParam: self.clickMeWidget.url
                ])
                if let url = URL(string: self.clickMeWidget.url) {
                    UIApplication.shared.open(url)
                }
            })
        })
    }
}
