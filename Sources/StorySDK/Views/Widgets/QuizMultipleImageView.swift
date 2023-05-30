//
//  QuizMultipleImageView.swift
//  StorySDK
//
//  Created by Ingvarr Alef on 09.05.2023.
//

import UIKit
import Combine

protocol QuizMultipleImageViewDelegate: AnyObject {
    func didChooseQuizMultipleImageAnswer(_ widget: QuizMultipleImageView, isYes: Bool)
}

class QuizMultipleImageView: SRInteractiveWidgetView {
    let quizWidget: SRQuizMultipleImageWidget
    
    private let buttonsView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.backgroundColor = .clear//SRThemeColor.white.color
        sv.spacing = 20
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
    
    let firstImageView: UIImageView = {
        let v = UIImageView(frame: .zero)
        v.contentMode = .scaleAspectFit
        v.isHidden = true
        v.isUserInteractionEnabled = false
        return v
    }()
    
    let secondImageView: UIImageView = {
        let v = UIImageView(frame: .zero)
        v.contentMode = .scaleAspectFit
        v.isHidden = true
        v.isUserInteractionEnabled = false
        return v
    }()
    
    //let url: URL?
    var urls: [URL?] = [URL?]()
    let logger: SRLogger
    weak var loader: SRImageLoader?
    private var loadingTask: Cancellable? {
        didSet { oldValue?.cancel() }
    }
    
    private var loadingTask2: Cancellable? {
        didSet { oldValue?.cancel() }
    }
    
    private let firstAnswerLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.textAlignment = .center
        l.textColor = SRThemeColor.black.color
        return l
    }()
    
    private let secondAnswerLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.textAlignment = .center
        l.textColor = SRThemeColor.black.color
        return l
    }()
    
    private let firstView: UIView = {
        let v = UIView(frame: .zero)
        v.backgroundColor = SRThemeColor.white.color
        //b.tag = 0
        //b.tintColor = SRThemeColor.black.color
        return v
    }()
    
    private let secondView: UIView = {
        let v = UIView(frame: .zero)
        v.backgroundColor = SRThemeColor.white.color
        //b.tag = 0
        //b.tintColor = SRThemeColor.black.color
        return v
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
    
    init(story: SRStory, data: SRWidget, quizWidget: SRQuizMultipleImageWidget, loader: SRImageLoader, logger: SRLogger) {
        self.quizWidget = quizWidget
        self.urls = quizWidget.answers.map {$0.image?.url }
        self.loader = loader
        self.logger = logger
        
        super.init(story: story, data: data)
    }
    
    private var oldSize = CGSize.zero
    private func updateImage(url: URL?, imView: UIImageView, _ size: CGSize, completion: @escaping () -> Void) -> Cancellable? {
        guard let url = url,
              let loader = loader else {
                //,
              //abs(size.width - oldSize.width) > .ulpOfOne,
              //abs(size.height - oldSize.height) > .ulpOfOne else {
            completion()
            return nil
        }
        oldSize = size
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)
        return loader.load(url, size: targetSize) { [weak self, logger] result in
            defer { completion() }
            switch result {
            case .success(let image):
                //self?.contentView.isHidden = true
                imView.isHidden = false
                imView.image = image
            case .failure(let error):
                //self?.contentView.isHidden = false
                imView.isHidden = true
                logger.error(error.localizedDescription, logger: .widgets)
            }
        }
    }
    
    override func setupView() {
        super.setupView()
        
        [firstImageView, firstAnswerLabel].forEach(firstView.addSubview)
        [secondImageView, secondAnswerLabel].forEach(secondView.addSubview)
        
        [titleLabel, buttonsView, grayView].forEach(contentView.addSubview)
        
        titleLabel.font = .regular(fontFamily: quizWidget.titleFont.fontFamily, ofSize: 12.0)
        titleLabel.text = quizWidget.title
        
        let confirmAnswer = quizWidget.answers.first?.title ?? "First"
        let declineAnswer = quizWidget.answers.last?.title ?? "Last"
        
        firstAnswerLabel.text = confirmAnswer
        secondAnswerLabel.text = declineAnswer
        
        yesButton.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
        
        switch quizWidget.answersFont.fontColor {
        case .color(let color, _):
            yesButton.tintColor = color
            noButton.tintColor = color
        default:
            yesButton.tintColor = SRThemeColor.black.color
            noButton.tintColor = SRThemeColor.black.color
        }
        
        //buttonsView.addArrangedSubview(yesButton)
        buttonsView.addArrangedSubview(firstView)
        
        noButton.setTitle(declineAnswer, for: .normal)
        noButton.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
        
        
        buttonsView.addArrangedSubview(secondView)
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
        
        titleLabel.font = .font(family: quizWidget.titleFont.fontFamily, ofSize: 12.0 * scale, weight: .init(quizWidget.titleFont.fontParams.weight))
        firstAnswerLabel.font = .font(family: quizWidget.answersFont.fontFamily, ofSize: 12.0 * scale, weight: .init(quizWidget.answersFont.fontParams.weight))
        secondAnswerLabel.font = .font(family: quizWidget.answersFont.fontFamily, ofSize: 12.0 * scale, weight: .init(quizWidget.answersFont.fontParams.weight))
        
        let buttonsHeight = 150 * scale//50 * scale
        buttonsView.frame = .init(x: 0,
                                  y: /*contentView.frame.height - buttonsHeight*/75,
                                  width: contentView.frame.width,
                                  height: contentView.frame.height - 75)
        buttonsView.layer.cornerRadius = 10 * scale
        grayView.frame = .init(x: buttonsView.frame.midX - 0.5,
                               y: buttonsView.frame.minY,
                               width: 1,
                               height: buttonsView.frame.height)
        titleLabel.frame = .init(x: 0,
                                 y: 0,
                                 width: contentView.frame.width,
                                 height: buttonsView.frame.minY)
        
        firstImageView.frame = .init(x: 8,
                                     y: 8,
                                     width: firstView.bounds.width - 2 * 8,
                                     height: firstView.bounds.width - 2 * 8)
        secondImageView.frame = .init(x: 8,
                                      y: 8,
                                      width: secondView.bounds.width - 2 * 8,
                                      height: secondView.bounds.width - 2 * 8)
        
        firstAnswerLabel.frame = CGRect(x: 0, y: firstView.bounds.height - 30, width: firstView.bounds.width, height: 25)
        
        secondAnswerLabel.frame = CGRect(x: 0, y: secondView.bounds.height - 30, width: firstView.bounds.width, height: 25)
        
        updateImage(url: urls.first!, imView: firstImageView, bounds.size, completion: {}).map { loadingTask = $0 }
        
        updateImage(url: urls.last!, imView: secondImageView, bounds.size, completion: {}).map { loadingTask2 = $0 }
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
