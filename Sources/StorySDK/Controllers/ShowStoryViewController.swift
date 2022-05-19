//
//  ShowStoryViewController.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

class ShowStoryViewController: UIViewController {
    /// Основная вьюшка, куда будут добавляться виджеты. Сделана, чтобы не вылезать за safe area
    private lazy var storyView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        return v
    }()
    
    private lazy var indicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .large)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.tintColor = .lightGray
        return aiv
    }()

    private lazy var bgImageView: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFill
        v.backgroundColor = .clear
        v.isHidden = true
        return v
    }()

    private lazy var bgView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.clipsToBounds = true
        return v
    }()

    private let story: Story
    private let storyData: StoryData
    private let storySdk: StorySDK
    private var keyboardHeight: CGFloat = 0
    
    // MARK: - Initializers
    public init(_ story: Story, storyData: StoryData, sdk: StorySDK = .shared) {
        self.story = story
        self.storyData = storyData
        self.storySdk = sdk
        
        super.init(nibName: nil, bundle: nil)
        DispatchQueue.main.async {
            self.changeBackground()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        storyView.layoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.clipsToBounds = true
        
        // Оповещение, что скоро появится клавиатура
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        // Оповещение, что клавиатура скоро уберется
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        prepareUI()
    }
    
    private func prepareUI() {
        let config = storySdk.configuration
        
        let topAnchor: NSLayoutYAxisAnchor
        let bottomAnchor: NSLayoutYAxisAnchor
        if config.needFullScreen {
            topAnchor = view.topAnchor
            bottomAnchor = view.bottomAnchor
        } else {
            topAnchor = view.safeAreaLayoutGuide.topAnchor
            bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
        }
        let storyOffset: CGFloat = config.needShowTitle ? topViewHeight : 0
        
        view.addSubview(bgView)
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: topAnchor),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bgView.rightAnchor.constraint(equalTo: view.rightAnchor),
            bgView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])
        view.addSubview(bgImageView)
        
        NSLayoutConstraint.activate([
            bgImageView.topAnchor.constraint(equalTo: topAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bgImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            bgImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])
        
        view.addSubview(storyView)
        NSLayoutConstraint.activate([
            storyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: storyOffset),
            storyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            storyView.rightAnchor.constraint(equalTo: view.rightAnchor),
            storyView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])

        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        indicator.isHidden = true
        
        DispatchQueue.main.async {
            self.appendWidgets()
            self.view.setNeedsLayout()
        }
    }
    
    private func changeBackground() {
        guard let background = storyData.background else { return }
        switch background {
        case .color(let color):
            bgView.backgroundColor = color
        case .gradient(let colors):
            let l = Utils.getGradient(
                frame: view.bounds,
                colors: colors,
                points: [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 1)]
            )
            bgView.layer.insertSublayer(l, at: 0)
        case .image(let url):
            indicator.startAnimating()
            indicator.isHidden = false
            let bgSize = UIScreen.main.bounds.size
            let scale = UIScreen.main.scale
            storySdk.imageLoader.load(url, size: bgSize, scale: scale) { [weak self] result in
                defer {
                    self?.indicator.stopAnimating()
                    self?.indicator.isHidden = true
                }
                guard case .success(let image) = result else { return }
                self?.bgImageView.image = image
                self?.bgImageView.isHidden = false
            }
        }
    }
    
    private func appendWidgets() {
        for widget in storyData.widgets {
            let pos = widget.position
            var height: Double = 0.0
            var width: Double = 0.0
            var real_height: Double = 0.0
            var real_width: Double = 0.0
            switch pos.height {
            case .double(let value):
                height = value
            case .string( _):
                break
            }
            switch pos.width {
            case .double(let value):
                width = value
            case .string( _):
                break
            }
            let x = pos.x * xScaleFactor
            let y = pos.y * xScaleFactor
            if let realWidth = pos.realWidth, realWidth > 0 {
                real_width = realWidth
            }
            if let realHeight = pos.realHeight, realHeight > 0 {
                real_height = realHeight
            }
            real_width *= xScaleFactor
            real_height *= xScaleFactor
            let widgetFrame = CGRect(x: x, y: y, width: real_width, height: real_height)
            switch widget.content.params {
            case .rectangle(let rectangleWidget):           // !!!
                let v = RectangleView(frame: widgetFrame, data: widget, rectangleWidget: rectangleWidget)
                storyView.addSubview(v)
            case .ellipse(let ellipseWidget):               // !!!
                let v = EllipseView(frame: widgetFrame, data: widget, ellipseWidget: ellipseWidget)
                storyView.addSubview(v)
            case .emoji(let emojiReactionWidget):
                var scale: CGFloat = 1
                if let minHeight = widget.positionLimits.minHeight {
                    scale = height / (minHeight * xScaleFactor)
                }
                let v = EmojiReactionView(frame: widgetFrame, story: story, data: widget, emojiReactionWidget: emojiReactionWidget, scale: scale)
                storyView.addSubview(v)
            case .choose_answer(let chooseAnswerWidget):    // !!!
                let v = ChooseAnswerView(frame: widgetFrame, story: story, data: widget, chooseAnswerWidget: chooseAnswerWidget)
                storyView.addSubview(v)
            case .text(let textWidget):
                let textFrame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width * xScaleFactor, height: height * xScaleFactor))
                let v = TextView(frame: textFrame, data: widget, textWidget: textWidget)
                storyView.addSubview(v)
            case .swipe_up(let swipeUpWidget):
                let v = SwipeUpView(frame: widgetFrame, story: story, data: widget, swipeUpWidget: swipeUpWidget)
                storyView.addSubview(v)
            case .click_me(let clickMeWidget):              // !!!
                let v = ClickMeView(frame: widgetFrame, story: story, data: widget, clickMeWidget: clickMeWidget)
                storyView.addSubview(v)
            case .slider(let sliderWidget):                 // !!?
                let v = SliderView(frame: widgetFrame, story: story, data: widget, sliderWidget: sliderWidget)
                storyView.addSubview(v)
            case .question(let questionWidget):
                let v = QuestionView(frame: widgetFrame, story: story, data: widget, questionWidget: questionWidget, sdk: storySdk)
                storyView.addSubview(v)
            case .talk_about(let talkAboutWidget):
                var scale: CGFloat = 1
                if let minWidth = widget.positionLimits.minWidth {
                    scale = width / (minWidth * xScaleFactor)
                }
                let size = CGSize(width: width, height: height + 50 * scale)
                let rect = CGRect(origin: widgetFrame.origin, size: size)
                let v = TalkAboutView(frame: rect, story: story, data: widget, talkAboutWidget: talkAboutWidget, scale: scale)
                v.delegate = self
                storyView.addSubview(v)
            case .giphy(let giphyWidget):                   // !!!
                let v = GiphyView(frame: widgetFrame, data: widget, giphyWidget: giphyWidget)
                storyView.addSubview(v)
            case .timer(let timerWidget):
                let v = TimerView(frame: widgetFrame, story: story, data: widget, timerWidget: timerWidget)
                storyView.addSubview(v)
            }
        }
    }
}

// MARK: - TalkAbout Delegate
extension ShowStoryViewController: TalkAboutViewDelegate {
    func needShowKeyboard(_ widgetView: TalkAboutView) {
        if !widgetView.isTextFieldActive {
            return
        }
        // Посчитаем размеры
        let bottom = storyView.frame.height - (widgetView.frame.origin.y + widgetView.frame.size.height - 50 * widgetView.scaleFactor)
        let delta = keyboardHeight - bottom
        if delta > 0 {
            UIView.animate(withDuration: animationsDuration, animations: {
                self.storyView.transform = CGAffineTransform(translationX: 0, y: -delta)
            })
        }
    }
    
    func needHideKeyboard(_ widgetView: TalkAboutView) {
        UIView.animate(withDuration: animationsDuration, animations: {
            self.storyView.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        keyboardHeight = keyboardRectangle.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        keyboardHeight = 0
    }
}
