//
//  QuestionView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

#if os(macOS)
    import Cocoa

    class QuestionView: SRInteractiveWidgetView {
        let questionWidget: SRQuestionWidget
        
        init(story: SRStory, data: SRWidget, questionWidget: SRQuestionWidget) {
            self.questionWidget = questionWidget
            super.init(story: story, data: data)
        }
    }
#elseif os(iOS)
    import UIKit

    class QuestionView: SRInteractiveWidgetView {
        let questionWidget: SRQuestionWidget
        
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
            b.tintColor = SRThemeColor.green.color
            return b
        }()
        
        private let noButton: UIButton = {
            let b = UIButton(type: .system)
            b.tag = 1
            b.tintColor = SRThemeColor.orangeRed.color
            return b
        }()
        
        private let titleLabel: UILabel = {
            let l = UILabel()
            l.numberOfLines = 0
            l.textAlignment = .center
            l.textColor = SRThemeColor.white.color
            return l
        }()
        
        init(story: SRStory, defaultStorySize: CGSize, data: SRWidget, questionWidget: SRQuestionWidget) {
            self.questionWidget = questionWidget
            super.init(story: story, defaultStorySize: defaultStorySize, data: data)
        }
        
        override func setupView() {
            super.setupView()
            [titleLabel, buttonsView, grayView].forEach(contentView.addSubview)
            titleLabel.text = questionWidget.question
            
            yesButton.setTitle(questionWidget.confirm.uppercased(), for: .normal)
            yesButton.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
            buttonsView.addArrangedSubview(yesButton)
            
            noButton.setTitle(questionWidget.decline.uppercased(), for: .normal)
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
            titleLabel.font = .bold(ofSize: 14 * scale)
            yesButton.titleLabel?.font = .bold(ofSize: 24 * scale)
            noButton.titleLabel?.font = .bold(ofSize: 24 * scale)
            
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
            delegate?.didChooseQuestionAnswer(self, isYes: sender.tag == 0)
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
#endif

protocol QuestionViewDelegate: AnyObject {
    func didChooseQuestionAnswer(_ widget: QuestionView, isYes: Bool)
}

extension Bool {
    var questionWidgetString: String { self ? "confirm" : "decline" }
}
