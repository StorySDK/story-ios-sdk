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
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .clear
        return iv
    }()

    private lazy var bgView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.clipsToBounds = true
        return v
    }()

    private var story: Story!
    private var storyData: StoryData!
    private var keyboardHeight: CGFloat = 0
    
    // MARK: - Initializers
    public init(_ story: Story, storyData: StoryData) {
        self.story = story
        self.storyData = storyData
        
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
        view.addSubview(bgView)
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: needFullScreen ? self.view.topAnchor : self.view.safeAreaLayoutGuide.topAnchor),
            bgView.bottomAnchor.constraint(equalTo: needFullScreen ? self.view.bottomAnchor : self.view.safeAreaLayoutGuide.bottomAnchor),
            bgView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            bgView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
        ])
        view.addSubview(bgImageView)
        
        NSLayoutConstraint.activate([
            bgImageView.topAnchor.constraint(equalTo: needFullScreen ? self.view.topAnchor : self.view.safeAreaLayoutGuide.topAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: needFullScreen ? self.view.bottomAnchor : self.view.safeAreaLayoutGuide.bottomAnchor),
            bgImageView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            bgImageView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
        ])
        bgImageView.isHidden = true
        
        view.addSubview(storyView)
        NSLayoutConstraint.activate([
            storyView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: needShowTitle ? topViewHeight : 0),
            storyView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            storyView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            storyView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
        ])

        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
        indicator.isHidden = true
        DispatchQueue.main.async {
            self.appendWidgets()
            self.view.setNeedsLayout()
        }
    }
    
    private func changeBackground() {
        let bg = storyData.background
        switch bg {
        case .color(let value):
            setColoredBG(value)
        case .gradient(let value):
            setGradientBG(value)
        default:
            break
        }
    }
    
    private func setColoredBG(_ value: ColorValue) {
        if value.type == "color" {
            bgView.backgroundColor = Utils.getColor(value.value)
        } else if value.type == "image", let url = URL(string: value.value) {
            indicator.startAnimating()
            indicator.isHidden = false
            LazyImageLoader.shared.loadImage(url: url, completion: { image, error in
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    self.indicator.isHidden = true
                }
                if let error = error {
                    print(error.localizedDescription)
                } else if let image = image {
                    DispatchQueue.main.async {
                        self.bgImageView.image = image
                        self.bgImageView.isHidden = false
                    }
                }
            })
            view.setNeedsLayout()
        }
    }
    
    private func setGradientBG(_ value: GradientValue) {
        if value.type == "gradient", value.value.count > 1 {
            let startColor = Utils.getColor(value.value[0])
            let finishColor = Utils.getColor(value.value[1])
            
            let l = Utils.getGradient(frame: view.bounds, colors: [startColor, finishColor], points: [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 1)])
            bgView.layer.insertSublayer(l, at: 0)
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
                let v = QuestionView(frame: widgetFrame, story: story, data: widget, questionWidget: questionWidget)
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
