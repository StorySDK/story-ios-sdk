//
//  QuizMultipleImageView.swift
//  StorySDK
//
//  Created by Igor Efremov on 09.05.2023.
//

import UIKit

protocol QuizMultipleImageViewDelegate: AnyObject {
    func didChooseQuizMultipleImageAnswer(_ widget: QuizMultipleImageView, isYes: Bool)
}

class QuizMultipleImageView: SRInteractiveWidgetView {
    let quizWidget: SRQuizMultipleImageWidget
    
    private let buttonsView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.backgroundColor = SRThemeColor.white.color
        return sv
    }()
    
    private let grayView: UIView = {
        let v = UIView()
        v.backgroundColor = SRThemeColor.grey.color
        return v
    }()

    private let yesButton: UIButton = {
        let b = UIButton(type: .system)
        b.tag = 0
        b.tintColor = SRThemeColor.black.color
        return b
    }()
    
    private let noButton: UIButton = {
        let b = UIButton(type: .system)
        b.tag = 1
        b.tintColor = SRThemeColor.black.color
        return b
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.textAlignment = .center
        l.textColor = SRThemeColor.white.color
        return l
    }()
    
    init(story: SRStory, data: SRWidget, quizWidget: SRQuizMultipleImageWidget) {
        self.quizWidget = quizWidget
        super.init(story: story, data: data)
    }
    
    override func setupView() {
        super.setupView()
        [titleLabel, buttonsView, grayView].forEach(contentView.addSubview)
        titleLabel.text = quizWidget.title
        
        let confirmAnswer = quizWidget.answers.first?.title ?? "First"
        let declineAnswer = quizWidget.answers.last?.title ?? "Last"
        
        yesButton.setTitle(confirmAnswer, for: .normal)
        yesButton.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
        
        switch quizWidget.answersFont.fontColor {
        case .color(let color, _):
            yesButton.tintColor = color
            noButton.tintColor = color
        default:
            yesButton.tintColor = SRThemeColor.black.color
            noButton.tintColor = SRThemeColor.black.color
        }
        
        buttonsView.addArrangedSubview(yesButton)
        noButton.setTitle(declineAnswer, for: .normal)
        noButton.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
        buttonsView.addArrangedSubview(noButton)
    }
    
    override func setupContentLayer(_ layer: CALayer) {
        layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let scale = widgetScale
        titleLabel.font = .bold(ofSize: 16 * scale)
        yesButton.titleLabel?.font = .medium(ofSize: 14 * scale)
        noButton.titleLabel?.font = .medium(ofSize: 14 * scale)
        
        let buttonsHeight = 50 * scale
        buttonsView.frame = .init(x: 0,
                                  y: contentView.frame.height - buttonsHeight,
                                  width: contentView.frame.width,
                                  height: buttonsHeight)
        buttonsView.layer.cornerRadius = 10 * scale
        grayView.frame = .init(x: buttonsView.frame.midX - 0.5,
                               y: buttonsView.frame.minY,
                               width: 1,
                               height: buttonsView.frame.height)
        titleLabel.frame = .init(x: 0,
                                 y: 0,
                                 width: contentView.frame.width,
                                 height: buttonsView.frame.minY)
    }
    
    @objc func answerTapped(_ sender: UIButton) {
        delegate?.didChooseQuizMultipleImageAnswer(self, isYes: sender.tag == 0)
        let b = sender.tag == 0 ? noButton : yesButton
        grayView.isHidden = true
        UIView.animate(withDuration: 0.5, animations: { b.isHidden = true })
    }
    
    override func setupWidget(reaction: String) {
        isUserInteractionEnabled = false
        let isTrue = true.questionWidgetString == reaction
        grayView.isHidden = true
        (isTrue ? noButton : yesButton).isHidden = true
    }
}
