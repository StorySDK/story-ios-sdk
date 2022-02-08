//
//  ChooseAnswerView.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

final class ChooseAnswerView: UIView {
    private var story: Story!
    private var data: WidgetData!
    private var chooseAnswerWidget: ChooseAnswerWidget!
    
    private lazy var answersView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        
        return v
    }()

    private var answerViews = [AnswerView]()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(frame: CGRect, story: Story, data: WidgetData, chooseAnswerWidget: ChooseAnswerWidget) {
        self.init(frame: frame)
        self.story = story
        self.data = data
        self.chooseAnswerWidget = chooseAnswerWidget
        self.transform = CGAffineTransform.identity.rotated(by: data.position.rotate * .pi / 180)
        prepareUI()
    }
    
    private func prepareUI() {
        backgroundColor = .clear
        layer.cornerRadius = 10
        clipsToBounds = true
        layer.shadowColor = black.withAlphaComponent(0.15).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4
        if chooseAnswerWidget.color == "purple" {
            let colors = [purpleStart, purpleFinish]
            let points = [CGPoint(x: 0.02, y: 0), CGPoint(x: 0.96, y: 0)]
            let l = Utils.getGradient(frame: bounds, colors: colors, points: points)
            l.cornerRadius = 10
            layer.insertSublayer(l, at: 0)
        }
        else {
            backgroundColor = Utils.getSolidColor(chooseAnswerWidget.color)
        }
        let text = chooseAnswerWidget.text
        var fontScaleFactor: CGFloat = 1
        if let minWidth = data.positionLimits.minWidth {
            fontScaleFactor *= frame.width / CGFloat(minWidth)
        }
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.getFont(name: "Inter-SemiBold", size: 12 * fontScaleFactor)
        label.text = text.uppercased()
        label.textAlignment = .center
        if chooseAnswerWidget.color == "white" {
            label.textColor = black
        }
        else {
            label.textColor = .white
        }
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 13 * xScaleFactor)
        ])
        
        addSubview(answersView)
        NSLayoutConstraint.activate([
            answersView.leftAnchor.constraint(equalTo: leftAnchor),
            answersView.rightAnchor.constraint(equalTo: rightAnchor),
            answersView.topAnchor.constraint(equalTo: topAnchor, constant: 52 * xScaleFactor),
            answersView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        answersView.addSubview(sv)
        NSLayoutConstraint.activate([
            sv.leftAnchor.constraint(equalTo: answersView.leftAnchor, constant: 16),
            sv.rightAnchor.constraint(equalTo: answersView.rightAnchor, constant: -16),
            sv.centerYAnchor.constraint(equalTo: answersView.centerYAnchor)
        ])
        sv.axis = .vertical
        sv.spacing = 8
        sv.distribution = .fillEqually
    
        for i in 0 ..< chooseAnswerWidget.answers.count {
            let rect = CGRect(origin: CGPoint.zero, size: CGSize(width: frame.width - 32, height: 34 * xScaleFactor))
            let av = AnswerView(frame: rect, answer: chooseAnswerWidget.answers[i], index: i, fontScaleFactor: fontScaleFactor)
            av.answerHandler = {[weak self] index in
                guard let self = self else { return }
                self.answerClicked(index: index)
            }
            answerViews.append(av)
            sv.addArrangedSubview(av)
        }
        setNeedsLayout()
    }
    
    @objc private func answerClicked(index: Int) {
        isUserInteractionEnabled = false
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: disableSwipeNotificanionName), object: nil)
        let answeredIndex = index
        var correctIndex: Int = 0
        
        for i in 0 ..< chooseAnswerWidget.answers.count {
            if chooseAnswerWidget.correct == chooseAnswerWidget.answers[i].id {
                correctIndex = i
                break
            }
        }
        if answeredIndex == correctIndex {
            for i in 0 ..< answerViews.count {
                if i == answeredIndex {
                    answerViews[i].setCorrectAnswerStatus()
                }
                else {
                    answerViews[i].setFinishAnswerStatus(isInCorrect: false)
                }
            }
            animateCorrectView(id: chooseAnswerWidget.answers[answeredIndex].id)
        }
        else {
            for i in 0 ..< answerViews.count {
                if i == correctIndex {
                    answerViews[i].setCorrectAnswerStatus()
                }
                else {
                    answerViews[i].setFinishAnswerStatus(isInCorrect: i == answeredIndex)
                }
            }
            animateInCorrectView(id: chooseAnswerWidget.answers[answeredIndex].id)
        }
    }
}

//MARK: - Animations
extension ChooseAnswerView {
    private func animateCorrectView(id: String) {
        UIView.animate(withDuration: animationsDuration, animations: {
            self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }, completion: {_ in
            UIView.animate(withDuration: animationsDuration, animations: {
                self.transform = CGAffineTransform.identity
            }, completion: {_ in
                self.sendMessage(id: id)
            })
        })
    }
    
    private func animateInCorrectView(id: String) {
        CATransaction.begin()
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x");
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.values = [-10, 10, -8, 8, -6, 6, -3, 3, 0]
        animation.duration = 0.5
        animation.isRemovedOnCompletion = true

        layer.add(animation, forKey: "shake")
        CATransaction.setCompletionBlock {
            self.sendMessage(id: id)
        }

        CATransaction.commit()
    }

    private func sendMessage(id: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: sendStatisticNotificationName), object: nil, userInfo: [
                widgetTypeParam: statisticAnswerParam,
                groupIdParam: self.story.group_id,
                storyIdParam: self.story.id,
                widgetIdParam: self.data.id,
                widgetValueParam: id
            ])
        }
    }
}

//MARK: - AnswerView
final class AnswerView: UIView {
    var answerHandler: ((_ index: Int) -> ())?

    private lazy var idView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        
        return v
    }()
    
    private lazy var idLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false

        return l
    }()
    
    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        
        return l
    }()
    
    private lazy var iconView: UIView = {
        let iv = UIView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .clear
        
        return iv
    }()

    private var answer: AnswerValue!
    private var index: Int = 0
    private var iconSize = CGSize(width: 14, height: 14)

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(frame: CGRect, answer: AnswerValue, index: Int, fontScaleFactor: CGFloat) {
        self.init(frame: CGRect.zero)
        
        self.answer = answer
        self.index = index
        prepareUI(fontScaleFactor: fontScaleFactor)
    }
    
    private func prepareUI(fontScaleFactor: CGFloat) {
        backgroundColor = .clear
        layer.cornerRadius = 17 * xScaleFactor
        layer.borderWidth = 1
        layer.borderColor = gray.cgColor
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 34 * xScaleFactor)
        ])

        iconSize = CGSize(width: 18 * xScaleFactor, height: 18 * xScaleFactor)
        
        addSubview(iconView)
        NSLayoutConstraint.activate([
            iconView.heightAnchor.constraint(equalToConstant: 24 * xScaleFactor),
            iconView.widthAnchor.constraint(equalToConstant: 24 * xScaleFactor),
            iconView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        iconView.layer.cornerRadius = 12 * xScaleFactor
        iconView.isHidden = true
        
        addSubview(idView)
        NSLayoutConstraint.activate([
            idView.heightAnchor.constraint(equalToConstant: 18 * xScaleFactor),
            idView.widthAnchor.constraint(equalToConstant: 18 * xScaleFactor),
            idView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12),
            idView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        idView.layer.cornerRadius = 9 * xScaleFactor
        idView.layer.borderWidth = 1
        idView.layer.borderColor = darkGray.cgColor

        let font = UIFont.getFont(name: "Inter-Regular", size: 10 * fontScaleFactor)
        idView.addSubview(idLabel)
        NSLayoutConstraint.activate([
            idLabel.centerXAnchor.constraint(equalTo: idView.centerXAnchor),
            idLabel.centerYAnchor.constraint(equalTo: idView.centerYAnchor)
        ])
        idLabel.font = font
        idLabel.textColor = darkGray
        idLabel.text = answer.id
        
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: idView.rightAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        titleLabel.font = font
        titleLabel.textColor = darkGray
        titleLabel.text = answer.title
        
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        addSubview(b)
        NSLayoutConstraint.activate([
            b.leftAnchor.constraint(equalTo: leftAnchor),
            b.rightAnchor.constraint(equalTo: rightAnchor),
            b.topAnchor.constraint(equalTo: topAnchor),
            b.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        b.tag = index
        b.addTarget(self, action: #selector(answerClicked(_:)), for: .touchUpInside)

    }
    
    @objc private func answerClicked(_ sender: UIButton) {
        answerHandler?(index)
    }
    
    func setCorrectAnswerStatus() {
        backgroundColor = green.withAlphaComponent(0.8)
        titleLabel.textColor = .white
        layer.borderWidth = 0
        if let maskImage = UIImage(named: "IconConfirm", in: Bundle(for: StoriesViewController.self), compatibleWith: nil) {
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            iconView.addSubview(iv)
            NSLayoutConstraint.activate([
                iv.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
                iv.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
                iv.widthAnchor.constraint(equalToConstant: iconSize.width),
                iv.heightAnchor.constraint(equalToConstant: iconSize.height)
            ])

            iv.image = maskImage.withTintColor(.white)
            iconView.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
            iconView.layer.borderWidth = 1
            iconView.isHidden = false
            idView.isHidden = true
        }
    }
    
    func setFinishAnswerStatus(isInCorrect: Bool) {
        if let maskImage = UIImage(named: "IconDecline", in: Bundle(for: StoriesViewController.self), compatibleWith: nil) {
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            iconView.addSubview(iv)
            NSLayoutConstraint.activate([
                iv.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
                iv.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
                iv.widthAnchor.constraint(equalToConstant: iconSize.width),
                iv.heightAnchor.constraint(equalToConstant: iconSize.height)
            ])

            iv.image = maskImage.withTintColor(.red)
            iconView.layer.borderColor = red.withAlphaComponent(0.5).cgColor
            iconView.layer.borderWidth = 1
            iconView.backgroundColor = .white
            iconView.isHidden = false
            idView.isHidden = true
        }
        if isInCorrect {
            backgroundColor = red.withAlphaComponent(0.8)
            titleLabel.textColor = .white
            layer.borderWidth = 0
        }
        else {
            backgroundColor = .clear
            titleLabel.alpha = 0.5
        }
    }
}
