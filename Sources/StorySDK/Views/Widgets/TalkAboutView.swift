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
    var scaleFactor: CGFloat = 1
    var isTextFieldActive = false
    let loader: SRImageLoader
    
    private var imageLoadOperation: Cancellable?
    private let mainView: UIView = {
        let v = UIView()
        v.clipsToBounds = false
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.layer.masksToBounds = true
        iv.layer.borderWidth = 2
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
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
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    private let gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.startPoint = CGPoint(x: 0.0, y: 0.5)
        l.endPoint = CGPoint(x: 1.0, y: 0.5)
        l.masksToBounds = true
        return l
    }()

    init(story: SRStory, data: SRWidget, talkAboutWidget: SRTalkAboutWidget, scale: CGFloat, loader: SRImageLoader) {
        self.talkAboutWidget = talkAboutWidget
        self.scaleFactor = scale
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
        [titleLabel].forEach(mainView.addSubview)
    }
    
    override func setupView() {
        super.setupView()
        let imageSize = CGSize(width: 36 * scaleFactor, height: 36 * scaleFactor)
        
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: topAnchor, constant: imageSize.height / 2),
            mainView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            mainView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
        ])

        gradientLayer.colors = talkAboutWidget.color.gradient.map(\.cgColor)
        imageView.layer.borderColor = talkAboutWidget.color.cgColor
        mainView.layer.cornerRadius = 10 * xScaleFactor
        
        imageView.image = UIImage(named: "logo", in: Bundle.module, compatibleWith: nil)
        
        if let url = talkAboutWidget.image {
            imageLoadOperation = loader.load(url, size: imageSize, scale: UIScreen.main.scale) { [weak imageView] result in
                guard case .success(let image) = result else { return }
                imageView?.image = image
            }
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: imageSize.width),
            imageView.heightAnchor.constraint(equalToConstant: imageSize.height),
        ])

        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = SRThemeColor.black.color.withAlphaComponent(0.15)
        v.layer.cornerRadius = 8

        mainView.addSubview(v)
//        mainView.layer.shadowColor = black.withAlphaComponent(0.15).cgColor
//        mainView.layer.shadowOpacity = 1
//        mainView.layer.shadowOffset = .zero
//        mainView.layer.shadowRadius = 4
        
        NSLayoutConstraint.activate([
            v.leftAnchor.constraint(equalTo: mainView.leftAnchor, constant: 11),
            v.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
            v.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -11),
        ])
        
        v.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.leftAnchor.constraint(equalTo: v.leftAnchor, constant: 4),
            textField.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            textField.topAnchor.constraint(equalTo: v.topAnchor, constant: 12 * xScaleFactor),
            textField.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -12 * xScaleFactor),
        ])

        let labelFont = UIFont.regular(ofSize: 14 * scaleFactor)
        textField.font = .regular(ofSize: 16 * scaleFactor)
        textField.attributedPlaceholder = NSAttributedString(
            string: "Type something...",
            attributes: [
                .foregroundColor: SRThemeColor.black.color.withAlphaComponent(0.4),
                .font: labelFont,
            ]
        )
        textField.delegate = self

        titleLabel.font = labelFont
        titleLabel.text = talkAboutWidget.text
        if case .white = talkAboutWidget.color {
            titleLabel.textColor = SRThemeColor.black.color
        } else {
            titleLabel.textColor = SRThemeColor.white.color
        }
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: mainView.leftAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: v.topAnchor),
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.frame.height / 2
        gradientLayer.frame = mainView.bounds
        gradientLayer.cornerRadius = mainView.layer.cornerRadius
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
