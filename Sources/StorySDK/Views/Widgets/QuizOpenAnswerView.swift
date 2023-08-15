//
//  QuizOpenAnswerView.swift
//  StorySDK
//
//  Created by Igor Efremov on 15.05.2023.
//

import Combine
#if os(macOS)
    import Cocoa

    class QuizOpenAnswerView: SRInteractiveWidgetView {
        var widget: SRQuizOpenAnswerWidget
        
        
        init(story: SRStory, data: SRWidget, widget: SRQuizOpenAnswerWidget, loader: SRImageLoader) {
            self.widget = widget
            super.init(story: story, data: data)
        }
    }
#elseif os(iOS)
    import UIKit

    class QuizOpenAnswerView: SRInteractiveWidgetView {
        var widget: SRQuizOpenAnswerWidget
        var isTextFieldActive = false
        let loader: SRImageLoader
        weak var talkAboutDelegate: SRTalkAboutViewDelegate?
        override var delegate: SRInteractiveWidgetDelegate? {
            didSet { talkAboutDelegate = delegate }
        }
        
        private var imageLoadOperation: Cancellable?
        private let mainView: UIView = {
            let v = UIView()
            v.clipsToBounds = false
            return v
        }()
        
        private let titleLabel: UILabel = {
            let lbl = UILabel()
            lbl.textAlignment = .center
            lbl.numberOfLines = 0
            lbl.setContentCompressionResistancePriority(.required, for: .vertical)
            
            return lbl
        }()
        
        private let textField: UITextField = {
            let tf = UITextField()
            tf.backgroundColor = .clear
            tf.textColor = SRThemeColor.black.color
            tf.textAlignment = .center
            tf.keyboardType = .default
            tf.autocorrectionType = .no
            tf.spellCheckingType = .no
            tf.keyboardAppearance = .dark
            tf.returnKeyType = .done
            
            return tf
        }()
        private let textFieldContainer: UIView = {
            let v = UIView()
            v.backgroundColor = SRThemeColor.white.color.withAlphaComponent(0.15)
            return v
        }()
        private let gradientLayer: CAGradientLayer = {
            let l = CAGradientLayer()
            l.startPoint = CGPoint(x: 0.0, y: 0.5)
            l.endPoint = CGPoint(x: 1.0, y: 0.5)
            l.masksToBounds = true
            return l
        }()

        init(story: SRStory, data: SRWidget, widget: SRQuizOpenAnswerWidget, loader: SRImageLoader) {
            self.widget = widget
            self.loader = loader
            super.init(story: story, data: data)
        }
        
        deinit {
            imageLoadOperation?.cancel()
        }
        
        override func addSubviews() {
            super.addSubviews()
            mainView.layer.addSublayer(gradientLayer)
            [mainView].forEach(contentView.addSubview)
            [titleLabel, textFieldContainer, textField].forEach(mainView.addSubview)
        }
        
        override func setupView() {
            super.setupView()

    //        gradientLayer.colors = talkAboutWidget.color.gradient.map(\.cgColor)
    //        imageView.layer.borderColor = talkAboutWidget.color.cgColor
    //        imageView.image = UIImage(named: "logo", in: Bundle.module, compatibleWith: nil)
            
    //        if let url = talkAboutWidget.image {
    //            let scale = widgetScale
    //            let imageSize = CGSize(width: 36 * scale, height: 36 * scale)
    //            imageLoadOperation = loader.load(url, size: imageSize, scale: UIScreen.main.scale) { [weak imageView] result in
    //                guard case .success(let image) = result else { return }
    //                imageView?.image = image
    //            }
    //        }

    //        mainView.layer.shadowColor = black.withAlphaComponent(0.15).cgColor
    //        mainView.layer.shadowOpacity = 1
    //        mainView.layer.shadowOffset = .zero
    //        mainView.layer.shadowRadius = 4
            
            textField.delegate = self
            titleLabel.text = widget.title
            
            switch widget.fontColor {
            case .color(let color, _):
                titleLabel.textColor = color
            default:
                titleLabel.textColor = SRThemeColor.black.color
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            let scale = widgetScale
            
            mainView.frame = .init(x: 0,
                                   y: 0,
                                   width: contentView.frame.width,
                                   height: contentView.frame.height)
            mainView.layer.cornerRadius = 10 * scale
            gradientLayer.frame = mainView.bounds
            gradientLayer.cornerRadius = mainView.layer.cornerRadius
            
            titleLabel.font = .font(family: widget.fontFamily,
                                    ofSize: 12.0 * scale, weight: UIFont.Weight(widget.fontParams.weight))
            
            let padding = 12 * scale
            let textFieldHeight = 34 * scale
            textFieldContainer.frame = .init(x: padding,
                                              y: mainView.frame.height - padding - textFieldHeight,
                                              width: contentView.frame.width - padding * 2,
                                              height: textFieldHeight)
            textFieldContainer.layer.cornerRadius = textFieldHeight / 2
            
            textField.frame = textFieldContainer.frame.insetBy(dx: padding, dy: 4 * scale)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            
            textField.font = .regular(ofSize: 16 * scale)
            textField.attributedPlaceholder = NSAttributedString(
                string: "Enter the text...",
                attributes: [
                    .foregroundColor: titleLabel.textColor.withAlphaComponent(0.4),
                    .font: UIFont.regular(ofSize: 10 * scale),
                    .paragraphStyle: paragraphStyle
                ]
            )
            
            titleLabel.frame = .init(x: padding,
                                     y: 0,
                                     width: mainView.frame.width - padding * 2,
                                     height: textFieldContainer.frame.minY)
        }
        
        override func setupWidget(reaction: String) {
            guard !reaction.isEmpty else { return }
            textField.text = reaction
            isUserInteractionEnabled = false
        }
        
        @discardableResult
        override func becomeFirstResponder() -> Bool {
            textField.becomeFirstResponder()
        }
        
        @discardableResult
        override func resignFirstResponder() -> Bool {
            textField.resignFirstResponder()
        }
        
        func addTapGesture() {
    //        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
    //        addGestureRecognizer(gesture)
    //        textField.isUserInteractionEnabled = false
        }
        
    //    @objc func didTap() {
    //        talkAboutDelegate?.needShowKeyboard(self)
    //    }
    }

    // MARK: - TextField
    extension QuizOpenAnswerView: UITextFieldDelegate {
        func textFieldDidBeginEditing(_ textField: UITextField) {
            isTextFieldActive = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                //guard let wSelf = self else { return }
                //wSelf.talkAboutDelegate?.needShowKeyboard(wSelf)
            }
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            isTextFieldActive = false
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            //talkAboutDelegate?.didSentTextAbout(self, text: textField.text)
            isUserInteractionEnabled = false
            return true
        }
    }
#endif
