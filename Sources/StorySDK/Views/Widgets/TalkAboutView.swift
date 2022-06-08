//
//  TalkAboutView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit
import Combine

protocol TalkAboutViewDelegate: AnyObject {
    func needShowKeyboard(_ widget: TalkAboutView)
    func needHideKeyboard(_ widget: TalkAboutView)
    func didSentTextAbout(_ widget: TalkAboutView, text: String?)
}

class TalkAboutView: SRInteractiveWidgetView {
    var talkAboutWidget: SRTalkAboutWidget
    var isTextFieldActive = false
    let loader: SRImageLoader
    
    private var imageLoadOperation: Cancellable?
    private let mainView: UIView = {
        let v = UIView()
        v.clipsToBounds = false
        return v
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.layer.borderWidth = 2
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.numberOfLines = 0
        l.setContentCompressionResistancePriority(.required, for: .vertical)
        return l
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
        v.backgroundColor = SRThemeColor.black.color.withAlphaComponent(0.15)
        return v
    }()
    private let gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.startPoint = CGPoint(x: 0.0, y: 0.5)
        l.endPoint = CGPoint(x: 1.0, y: 0.5)
        l.masksToBounds = true
        return l
    }()

    init(story: SRStory, data: SRWidget, talkAboutWidget: SRTalkAboutWidget, loader: SRImageLoader) {
        self.talkAboutWidget = talkAboutWidget
        self.loader = loader
        super.init(story: story, data: data)
    }
    
    deinit {
        imageLoadOperation?.cancel()
    }
    
    override func addSubviews() {
        super.addSubviews()
        mainView.layer.addSublayer(gradientLayer)
        [mainView, imageView].forEach(contentView.addSubview)
        [titleLabel, textFieldContainer, textField].forEach(mainView.addSubview)
    }
    
    override func setupView() {
        super.setupView()

        gradientLayer.colors = talkAboutWidget.color.gradient.map(\.cgColor)
        imageView.layer.borderColor = talkAboutWidget.color.cgColor
        imageView.image = UIImage(named: "logo", in: Bundle.module, compatibleWith: nil)
        
        if let url = talkAboutWidget.image {
            let scale = widgetScale
            let imageSize = CGSize(width: 36 * scale, height: 36 * scale)
            imageLoadOperation = loader.load(url, size: imageSize, scale: UIScreen.main.scale) { [weak imageView] result in
                guard case .success(let image) = result else { return }
                imageView?.image = image
            }
        }

//        mainView.layer.shadowColor = black.withAlphaComponent(0.15).cgColor
//        mainView.layer.shadowOpacity = 1
//        mainView.layer.shadowOffset = .zero
//        mainView.layer.shadowRadius = 4
        
        textField.delegate = self
        
        titleLabel.text = talkAboutWidget.text
        if case .white = talkAboutWidget.color {
            titleLabel.textColor = SRThemeColor.black.color
        } else {
            titleLabel.textColor = SRThemeColor.white.color
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let scale = widgetScale
        let iconSize = 36 * scale
        imageView.frame = .init(x: contentView.frame.midX - iconSize / 2,
                                y: 0,
                                width: iconSize,
                                height: iconSize)
        imageView.layer.cornerRadius = iconSize / 2
        mainView.frame = .init(x: 0,
                               y: iconSize / 2,
                               width: contentView.frame.width,
                               height: contentView.frame.height - iconSize / 2)
        mainView.layer.cornerRadius = 10 * scale
        gradientLayer.frame = mainView.bounds
        gradientLayer.cornerRadius = mainView.layer.cornerRadius
        
        let labelFont = UIFont.regular(ofSize: 14 * scale)
        titleLabel.font = labelFont
        let padding = 12 * scale
        let textFieldHeight = 34 * scale
        textFieldContainer.frame = .init(x: padding,
                                          y: mainView.frame.height - padding - textFieldHeight,
                                          width: contentView.frame.width - padding * 2,
                                          height: textFieldHeight)
        textFieldContainer.layer.cornerRadius = 8 * scale
        
        textField.frame = textFieldContainer.frame.insetBy(dx: padding, dy: 4 * scale)
        
        textField.font = .regular(ofSize: 16 * scale)
        textField.attributedPlaceholder = NSAttributedString(
            string: "Type something...",
            attributes: [
                .foregroundColor: SRThemeColor.black.color.withAlphaComponent(0.4),
                .font: labelFont,
            ]
        )
        
        titleLabel.frame = .init(x: padding,
                                 y: iconSize / 2,
                                 width: mainView.frame.width - padding * 2,
                                 height: textFieldContainer.frame.minY - iconSize / 2)
    }
    
    override func setupWidget(reaction: String) {
        guard !reaction.isEmpty else { return }
        textField.text = reaction
        isUserInteractionEnabled = false
    }
}

// MARK: - TextField
extension TalkAboutView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        NotificationCenter.default.post(name: .disableSwipe, object: nil)
        isTextFieldActive = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            guard let wSelf = self else { return }
            wSelf.delegate?.needShowKeyboard(wSelf)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isTextFieldActive = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.needHideKeyboard(self)
        textField.resignFirstResponder()
        delegate?.didSentTextAbout(self, text: textField.text)
        isUserInteractionEnabled = false
        return true
    }
}
