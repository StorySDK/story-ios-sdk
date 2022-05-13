//
//  ClickMeView.swift
//  StorySDK
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

        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(meClicked(_:)))
        addGestureRecognizer(tapgesture)
    }
    
    @objc private func meClicked(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: disableSwipeNotificanionName), object: nil)
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
                    groupIdParam: self.story.groupId,
                    storyIdParam: self.story.id,
                    widgetIdParam: self.data.id,
                    widgetValueParam: self.clickMeWidget.url,
                ])
                if let url = URL(string: self.clickMeWidget.url) {
                    UIApplication.shared.open(url)
                }
            })
        })
    }
}
