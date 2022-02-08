//
//  TalkAboutView.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

protocol TalkAboutViewDelegate: AnyObject {
    func needShowKeyboard(_ widgetView: TalkAboutView)
    func needHideKeyboard(_ widgetView: TalkAboutView)
}

class TalkAboutView: UIView {
    private var story: Story!
    private var data: WidgetData!
    var talkAboutWidget: TalkAboutWidget!
    
    weak var delegate: TalkAboutViewDelegate?
    
    var scaleFactor: CGFloat = 1
    var isTextFieldActive = false
    
    private lazy var mainView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    private lazy var addView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    private lazy var sendView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        
        return v
    }()
    
    private lazy var sendButton: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        
        return b
    }()

    private lazy var logo: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    private lazy var label: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        
        return l
    }()
    
    private lazy var textField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(frame: CGRect, story: Story, data: WidgetData, talkAboutWidget: TalkAboutWidget, scale: CGFloat) {
        self.init(frame: frame)
        self.story = story
        self.data = data
        self.talkAboutWidget = talkAboutWidget
        self.scaleFactor = scale
        self.transform = CGAffineTransform.identity.rotated(by: data.position.rotate * .pi / 180)

        prepareUI()
    }
    
    private func prepareUI() {
        backgroundColor = .clear
        addSubview(mainView)
        addSubview(logo)
        mainView.clipsToBounds = false
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: topAnchor, constant: 18 * scaleFactor),
            mainView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50 * scaleFactor),
            mainView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            mainView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
        ])
        mainView.addSubview(addView)

        var bgColor = purpleFinish
        if talkAboutWidget.color == "purple" {
            let colors = [purpleStart, purpleFinish]
            let points = [CGPoint(x: 0.02, y: 0), CGPoint(x: 0.96, y: 0)]
            let l = Utils.getGradient(frame: bounds, colors: colors, points: points)
            l.cornerRadius = 10
            mainView.layer.insertSublayer(l, at: 0)
            addView.layer.insertSublayer(l, at: 0)
        }
        else {
            bgColor = Utils.getSolidColor(talkAboutWidget.color)
            mainView.backgroundColor = bgColor
            addView.backgroundColor = bgColor
        }
        mainView.layer.cornerRadius = 10 * xScaleFactor
        
        if let img = UIImage(named: "IconLogoCircle", in: Bundle(for: StoriesViewController.self), compatibleWith: nil) {
            logo.image = img
        }
        
        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: topAnchor),
            logo.centerXAnchor.constraint(equalTo: centerXAnchor),
            logo.widthAnchor.constraint(equalToConstant: 36 * scaleFactor),
            logo.heightAnchor.constraint(equalToConstant: 36 * scaleFactor)
        ])

        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = black.withAlphaComponent(0.15)
        v.layer.cornerRadius = 8

        let lv = UIView()
        lv.translatesAutoresizingMaskIntoConstraints = false
        lv.backgroundColor = .clear

        mainView.addSubview(lv)
        mainView.addSubview(v)
        mainView.layer.shadowColor = black.withAlphaComponent(0.15).cgColor
        mainView.layer.shadowOpacity = 1
        mainView.layer.shadowOffset = .zero
        mainView.layer.shadowRadius = 4
        
        NSLayoutConstraint.activate([
            addView.leftAnchor.constraint(equalTo: mainView.leftAnchor),
            addView.rightAnchor.constraint(equalTo: mainView.rightAnchor),
            addView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
            addView.heightAnchor.constraint(equalToConstant: 11 * xScaleFactor)
        ])
        addView.isHidden = true
        
        NSLayoutConstraint.activate([
            v.leftAnchor.constraint(equalTo: mainView.leftAnchor, constant: 11),
            v.rightAnchor.constraint(equalTo: mainView.rightAnchor, constant: -11),
            v.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -11)
        ])
        
        v.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.leftAnchor.constraint(equalTo: v.leftAnchor, constant: 4),
            textField.rightAnchor.constraint(equalTo: v.rightAnchor, constant: -4),
            textField.topAnchor.constraint(equalTo: v.topAnchor, constant: 12 * xScaleFactor),
            textField.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -12 * xScaleFactor)
        ])

        let textFont = UIFont.getFont(name: "Inter-Regular", size: 16 * scaleFactor)
        let labelFont = UIFont.getFont(name: "Inter-Regular", size: 14 * scaleFactor)

        textField.backgroundColor = .clear
        textField.textColor = black
        textField.textAlignment = .center
        textField.font = textFont
        textField.attributedPlaceholder = NSAttributedString(string: "Type something...", attributes: [NSAttributedString.Key.foregroundColor: black.withAlphaComponent(0.4), NSAttributedString.Key.font: labelFont])
        textField.keyboardType = .default
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.keyboardAppearance = .dark
        textField.returnKeyType = .done
        textField.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        textField.delegate = self
        
        NSLayoutConstraint.activate([
            lv.leftAnchor.constraint(equalTo: mainView.leftAnchor, constant: 8),
            lv.rightAnchor.constraint(equalTo: mainView.rightAnchor, constant: -8),
            lv.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 18 * scaleFactor),
            lv.bottomAnchor.constraint(equalTo: v.topAnchor)
        ])
                
        lv.addSubview(label)
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: lv.leftAnchor),
            label.rightAnchor.constraint(equalTo: lv.rightAnchor),
            label.centerYAnchor.constraint(equalTo: lv.centerYAnchor)
        ])

        label.font = labelFont
        label.text = talkAboutWidget.text
        label.textColor = .white
        if talkAboutWidget.color == "white" {
            label.textColor = black
        }
        label.textAlignment = .center
        label.numberOfLines = 0

        addSubview(sendView)
        NSLayoutConstraint.activate([
            sendView.leftAnchor.constraint(equalTo: leftAnchor),
            sendView.rightAnchor.constraint(equalTo: rightAnchor),
            sendView.bottomAnchor.constraint(equalTo: bottomAnchor),
            sendView.topAnchor.constraint(equalTo: mainView.bottomAnchor)
        ])
        sendView.layer.cornerRadius = 8 * xScaleFactor
        let whiteView = UIView()
        whiteView.translatesAutoresizingMaskIntoConstraints = false
        whiteView.backgroundColor = .white
        sendView.addSubview(whiteView)
        NSLayoutConstraint.activate([
            whiteView.leftAnchor.constraint(equalTo: sendView.leftAnchor),
            whiteView.rightAnchor.constraint(equalTo: sendView.rightAnchor),
            whiteView.topAnchor.constraint(equalTo: sendView.topAnchor),
            whiteView.heightAnchor.constraint(equalToConstant: 11 * xScaleFactor)
        ])

        let lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        sendView.addSubview(lineView)
        NSLayoutConstraint.activate([
            lineView.leftAnchor.constraint(equalTo: sendView.leftAnchor),
            lineView.rightAnchor.constraint(equalTo: sendView.rightAnchor),
            lineView.topAnchor.constraint(equalTo: sendView.topAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 2)
        ])
        lineView.backgroundColor = bgColor.withAlphaComponent(0.25)
        if talkAboutWidget.color == "white" {
            lineView.backgroundColor = black.withAlphaComponent(0.25)
        }

        sendView.addSubview(sendButton)
        NSLayoutConstraint.activate([
            sendButton.leftAnchor.constraint(equalTo: sendView.leftAnchor),
            sendButton.rightAnchor.constraint(equalTo: sendView.rightAnchor),
            sendButton.topAnchor.constraint(equalTo: sendView.topAnchor),
            sendButton.bottomAnchor.constraint(equalTo: sendView.bottomAnchor)
        ])
        sendButton.setTitle("SEND", for: [])
        sendButton.setTitleColor(bgColor, for: [])
        if talkAboutWidget.color == "white" {
            sendButton.setTitleColor(black, for: [])
        }
        sendButton.titleLabel?.font = labelFont
        sendButton.addTarget(self, action: #selector(sendTapped(_:)), for: .touchUpInside)
        
        sendView.isHidden = true
    }

}

//MARK: - Actions
extension TalkAboutView {
    @objc func sendTapped(_ sender: UIButton) {
        var txt = ""
        if let text = textField.text {
            txt = text
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: sendStatisticNotificationName), object: nil, userInfo: [
            widgetTypeParam: statisticAnswerParam,
            groupIdParam: self.story.group_id,
            storyIdParam: self.story.id,
            widgetIdParam: self.data.id,
            widgetValueParam: txt
        ])
        sendButton.setTitleColor(green, for: [])
        sendButton.setTitle("SENT!", for: [])
        isUserInteractionEnabled = false
    }
}

//MARK: - TextField
extension TalkAboutView: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: disableSwipeNotificanionName), object: nil)
        isTextFieldActive = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.delegate?.needShowKeyboard(self)
        }
        sendView.isHidden = true
        addView.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isTextFieldActive = false
        checkReady()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.needHideKeyboard(self)
        textField.resignFirstResponder()

        return true
    }
    
    @objc func textFieldDidChanged(_ sender: UITextField) {
//        if textField.text != nil && textField.text! == "" {
//            checkReady()
//        }
    }
    
    private func checkReady() {
        let ready = textField.text != nil && textField.text! != ""
        sendView.isHidden = !ready
        addView.isHidden = !ready
        mainView.layer.shadowRadius = ready ? 0 : 4
    }
}
