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
                groupIdParam: self.story.groupId,
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
