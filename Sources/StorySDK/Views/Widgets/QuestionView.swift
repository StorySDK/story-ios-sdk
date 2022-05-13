//
//  QuestionView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

class QuestionView: UIView {
    /*
     const INIT_ELEMENT_STYLES = {
       text: {
         fontSize: 14,
         marginBottom: 10
       },
       button: {
         height: 50,
         fontSize: 24,
         borderRadius: 10
       }
     };

     */
    private let story: Story
    private let data: WidgetData
    private let questionWidget: QuestionWidget
    // TODO: Remove it
    private let storySdk: StorySDK
    
    private lazy var buttonsView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        return sv
    }()
    
    private lazy var grayView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = gray
        return v
    }()

    private lazy var yesButton: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private lazy var noButton: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 0
        l.textAlignment = .center
        return l
    }()
    
    init(frame: CGRect, story: Story, data: WidgetData, questionWidget: QuestionWidget, sdk: StorySDK) {
        self.story = story
        self.data = data
        self.questionWidget = questionWidget
        self.storySdk = sdk
        super.init(frame: frame)
        self.transform = CGAffineTransform.identity.rotated(by: data.position.rotate * .pi / 180)

        backgroundColor = .clear
        layer.cornerRadius = frame.height / 2
        layer.shadowColor = black.withAlphaComponent(0.15).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4
        clipsToBounds = false
        prepareUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareUI() {
        addSubview(titleLabel)
        addSubview(buttonsView)
        addSubview(grayView)
        NSLayoutConstraint.activate([
            grayView.centerXAnchor.constraint(equalTo: centerXAnchor),
            grayView.widthAnchor.constraint(equalToConstant: 1),
            grayView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            grayView.heightAnchor.constraint(equalToConstant: 50 * xScaleFactor - 8),
        ])
        
        NSLayoutConstraint.activate([
            buttonsView.leftAnchor.constraint(equalTo: leftAnchor),
            buttonsView.rightAnchor.constraint(equalTo: rightAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: bottomAnchor),
            buttonsView.heightAnchor.constraint(equalToConstant: 50 * xScaleFactor),
        ])

        buttonsView.layer.cornerRadius = 10 * xScaleFactor
        
        let color = Utils.getColor(questionWidget.color)
        buttonsView.backgroundColor = color
        titleLabel.textColor = .white
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: buttonsView.topAnchor),
        ])
        titleLabel.text = questionWidget.question
        var fontScaleFactor: CGFloat = 1
        if let minWidth = data.positionLimits.minWidth {
            fontScaleFactor *= frame.width / CGFloat(minWidth)
        }
        let font = UIFont.getFont(name: "Inter-Bold", size: 16 * fontScaleFactor)
        titleLabel.font = font
        
        yesButton.setTitle(questionWidget.confirm.uppercased(), for: [])
        yesButton.setTitleColor(green, for: [])
        yesButton.titleLabel?.font = font
        yesButton.tag = 0
        yesButton.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
        buttonsView.addArrangedSubview(yesButton)
        
        noButton.setTitle(questionWidget.decline.uppercased(), for: [])
        noButton.setTitleColor(orangeRed, for: [])
        noButton.titleLabel?.font = font
        noButton.tag = 1
        noButton.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
        buttonsView.addArrangedSubview(noButton)
    }
    
    @objc func answerTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: disableSwipeNotificanionName), object: nil)
        let answer = sender.tag == 0 ? "confirm" : "decline"
        let config = storySdk.configuration
        guard let reaction = WidgetReaction(
            storyId: story.id,
            groupId: story.groupId,
            userId: config.userId,
            widgetId: data.id,
            type: statisticAnswerParam,
            value: answer,
            locale: config.language
        ) else { return }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try! encoder.encode(reaction)
        storySdk.sendStatistic(jsonData) { result in
            switch result {
            case .success(let dict): print(dict)
            case .failure(let error): print(error.localizedDescription)
            }
        }

        let b = sender.tag == 0 ? noButton : yesButton
        grayView.isHidden = true
        UIView.animate(withDuration: 0.5, animations: {
            b.isHidden = true
        }, completion: {_ in
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: sendStatisticNotificationName), object: nil, userInfo: [
//                widgetTypeParam: statisticAnswerParam,
//                groupIdParam: self.story.group_id,
//                storyIdParam: self.story.id,
//                widgetIdParam: self.data.id,
//                widgetValueParam: answer
//            ])
        })
    }
}
