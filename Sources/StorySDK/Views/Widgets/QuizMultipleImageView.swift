//
//  QuizMultipleImageView.swift
//  StorySDK
//
//  Created by Igor Efremov on 09.05.2023.
//

import UIKit
import Combine

protocol QuizMultipleImageViewDelegate: AnyObject {
    func didChooseQuizMultipleImageAnswer(_ widget: QuizMultipleImageView, answer: String)
}

class QuizImageView: UIButton {
    var answer: SRAnswerValue?
    
    var answerFont: UIFont? {
        didSet {
            answerLabel.font = answerFont
        }
    }
    
    var text: String? {
        didSet {
            answerLabel.text = text
        }
    }
    
    var textColor: UIColor? {
        didSet {
            answerLabel.textColor = textColor
        }
    }
    
    let answerImageView: UIImageView = {
        let v = UIImageView(frame: .zero)
        v.contentMode = .scaleAspectFit
        v.isHidden = true
        v.isUserInteractionEnabled = false
        return v
    }()
    
    private let answerLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.textAlignment = .center
        l.textColor = SRThemeColor.black.color
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        prepareUI()
    }
    
    override func layoutSubviews() {
        let padding = 9.5
        
        super.layoutSubviews()
        answerImageView.frame = .init(x: padding,
                                     y: padding,
                                     width: bounds.width - 2 * padding,
                                      height: bounds.width - 2 * padding)
        
        answerLabel.frame = CGRect(x: 0, y: bounds.height - 30, width: bounds.width, height: 25)
    }
    
    private func prepareUI() {
        layer.cornerRadius = 8.0
        
        backgroundColor = SRThemeColor.white.color
        addSubview(answerImageView)
        addSubview(answerLabel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class QuizMultipleImageView: SRInteractiveWidgetView {
    let quizWidget: SRQuizMultipleImageWidget
    
    private let buttonsView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.backgroundColor = .clear//SRThemeColor.white.color
        sv.spacing = 11
        
        return sv
    }()
    
    let secondImageView: UIImageView = {
        let v = UIImageView(frame: .zero)
        v.contentMode = .scaleAspectFit
        v.isHidden = true
        v.isUserInteractionEnabled = false
        return v
    }()
    
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
    
    private let firstView: QuizImageView = {
        let v = QuizImageView(frame: .zero)
        
        return v
    }()
    
    private let secondView: QuizImageView = {
        let v = QuizImageView(frame: .zero)
        
        return v
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
                imView.isHidden = false
                imView.image = image
            case .failure(let error):
                imView.isHidden = true
                logger.error(error.localizedDescription, logger: .widgets)
            }
        }
    }
    
    override func setupView() {
        super.setupView()
        [titleLabel, buttonsView].forEach(contentView.addSubview)
        
        titleLabel.font = .regular(fontFamily: quizWidget.titleFont.fontFamily, ofSize: 12.0)
        titleLabel.text = quizWidget.title
        
        let confirmAnswer = quizWidget.answers.first?.title ?? "First"
        let declineAnswer = quizWidget.answers.last?.title ?? "Last"
        
        firstView.text = confirmAnswer
        secondView.text = declineAnswer
        
        buttonsView.addArrangedSubview(firstView)
        buttonsView.addArrangedSubview(secondView)
        
        firstView.addTarget(self, action: #selector(onTapAnswer(_:)), for: .touchUpInside)
        secondView.addTarget(self, action: #selector(onTapAnswer(_:)), for: .touchUpInside)
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
        firstView.answerFont = .font(family: quizWidget.answersFont.fontFamily, ofSize: 12.0 * scale, weight: .init(quizWidget.answersFont.fontParams.weight))
        
        secondView.answerFont = .font(family: quizWidget.answersFont.fontFamily, ofSize: 12.0 * scale, weight: .init(quizWidget.answersFont.fontParams.weight))
        let buttonsHeight = 150 * scale//50 * scale
        buttonsView.frame = .init(x: 0,
                                  y: /*contentView.frame.height - buttonsHeight*/75,
                                  width: contentView.frame.width,
                                  height: contentView.frame.height - 75)
        buttonsView.layer.cornerRadius = 10 * scale
        titleLabel.frame = .init(x: 0,
                                 y: 0,
                                 width: contentView.frame.width,
                                 height: buttonsView.frame.minY)
        updateImage(url: urls.first!, imView: firstView.answerImageView, bounds.size, completion: {}).map { loadingTask = $0 }
        
        updateImage(url: urls.last!, imView: secondView.answerImageView, bounds.size, completion: {}).map { loadingTask2 = $0 }
    }
    
    @objc func onTapAnswer(_ sender: QuizImageView) {
        if let id = sender.answer?.id {
            sendMessage(id: id, score: sender.answer?.score)
        }
        
        sender.backgroundColor = SRThemeColor.black.color
        sender.textColor = .white
    }
    
    private func sendMessage(id: String, score: SRScore?) {
        delegate?.didChooseQuizMultipleImageAnswer(self, answer: id)
    }
    
    override func setupWidget(reaction: String) {
        isUserInteractionEnabled = false
    }
}
