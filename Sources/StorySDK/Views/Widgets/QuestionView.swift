//
//  QuestionView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

protocol QuestionViewDelegate: AnyObject {
    func didChooseQuestionAnswer(_ widget: QuestionView, isYes: Bool)
}

class QuestionView: SRInteractiveWidgetView {
    let questionWidget: SRQuestionWidget
    
    private let buttonsView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        return sv
    }()
    
    private let grayView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.gray
        return v
    }()

    private let yesButton: UIButton = {
        let b = UIButton()
        b.tag = 0
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let noButton: UIButton = {
        let b = UIButton()
        b.tag = 1
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 0
        l.textAlignment = .center
        return l
    }()
    
    init(story: SRStory, data: SRWidget, questionWidget: SRQuestionWidget) {
        self.questionWidget = questionWidget
        super.init(story: story, data: data)
    }
    
    override func setupView() {
        super.setupView()
        
        [titleLabel, buttonsView, grayView].forEach(contentView.addSubview)
        
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
        
        buttonsView.backgroundColor = .white
        titleLabel.textColor = .white
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: buttonsView.topAnchor),
        ])
        titleLabel.text = questionWidget.question
        
        yesButton.setTitle(questionWidget.confirm.uppercased(), for: [])
        yesButton.setTitleColor(UIColor.green, for: [])
        yesButton.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
        buttonsView.addArrangedSubview(yesButton)
        
        noButton.setTitle(questionWidget.decline.uppercased(), for: [])
        noButton.setTitleColor(UIColor.orangeRed, for: [])
        noButton.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
        buttonsView.addArrangedSubview(noButton)
    }
    
    private func updateFontSize(scale: CGFloat) {
        let font = UIFont.getFont(name: "Inter-Bold", size: 16 * scale)
        titleLabel.font = font
        yesButton.titleLabel?.font = font
        noButton.titleLabel?.font = font
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
        contentView.layer.cornerRadius = frame.height / 2
        let xScale = data.positionLimits.minWidth.map { frame.width / CGFloat($0) } ?? 1
        updateFontSize(scale: xScale)
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

extension Bool {
    var questionWidgetString: String { self ? "confirm" : "decline" }
}
