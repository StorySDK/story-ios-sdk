//
//  StoriesViewController.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 04.02.2022.
//

import UIKit

public final class StoriesViewController: UIViewController {
    
    //MARK: - UI
    private lazy var topView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        let configuration = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(closeTapped(_:)), for: .touchUpInside)
        
        button.tintColor = .secondaryLabel
        button.contentMode = .scaleAspectFill
        button.isUserInteractionEnabled = true
        button.isAccessibilityElement = true
        button.accessibilityLabel = "Close Picker"
        
        return button
    }()

    private lazy var pageContainer: UIPageViewController = {
        let container = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        return container
    }()
    
    //MARK: - Data
    private var stories: [Story]!
    private var group: StoryGroup!
    
    private var currentIndex: Int = 0 {
        didSet {
//            print("========= current index = ", currentIndex, "==========")
        }
    }
    private var pendingIndex: Int?
    private var pages: [ShowStoryViewController]!
    private var activeOnly = false
    
    private var progressViews: [ProgressView]!
    

    //MARK: - Initializers
    public init(_ stories: [Story], for group: StoryGroup, activeOnly: Bool) {
        self.stories = stories.sorted(by: { $0.position < $1.position})
        self.group = group
        self.activeOnly = activeOnly
        
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View LifeCicle
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.systemBackground
        
        view.addSubview(pageContainer.view)
        view.addSubview(topView)

        view.addSubview(closeButton)

        prepareTop()
        prepareStories()
        layoutViews()
        if pages.count > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                self.pageContainer.setViewControllers([self.pages[0]], direction: .forward, animated: false, completion: nil)
                self.progressViews[0].start()
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: enableSwipeNotificanionName),
                                               object: nil,
                                               queue: nil,
                                               using: enableSwipe)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: disableSwipeNotificanionName),
                                               object: nil,
                                               queue: nil,
                                               using: disableSwipe)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: sendStatisticNotificationName),
                                               object: nil,
                                               queue: nil,
                                               using: needSendStatistics)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: startConfettiNotificationName),
                                               object: nil,
                                               queue: nil,
                                               using: startConfetti)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: enableSwipeNotificanionName), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: disableSwipeNotificanionName), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: sendStatisticNotificationName), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: startConfettiNotificationName), object: nil)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom
        let width = view.frame.width
        xScaleFactor =  width / editorWindowSize.width
        yScaleFactor = height / editorWindowSize.height
    }
    
    private func layoutViews() {
        NSLayoutConstraint.activate([
            topView.heightAnchor.constraint(equalToConstant: topViewHeight),
            topView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            topView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            topView.leftAnchor.constraint(equalTo: self.view.leftAnchor)
        ])
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -8)
        ])
    }
    
    private func prepareTop() {
        topView.isUserInteractionEnabled = false
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(v)
        NSLayoutConstraint.activate([
            v.widthAnchor.constraint(equalToConstant: topViewHeight - 16),
            v.heightAnchor.constraint(equalToConstant: topViewHeight - 16),
            v.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
            v.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 8)
        ])

        v.layer.cornerRadius = 24
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor.lightGray.cgColor
        v.isHidden = !needShowTitle

        v.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: v.topAnchor, constant: 4),
            imageView.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -4),
            imageView.leftAnchor.constraint(equalTo: v.leftAnchor, constant: 4),
            imageView.rightAnchor.constraint(equalTo: v.rightAnchor, constant: -4)
        ])
        imageView.layer.cornerRadius = (topViewHeight - 24) / 2
        imageView.clipsToBounds = true
        if let url = URL(string: group.getImageURL()) {
            LazyImageLoader.shared.loadImage(url: url, completion: { image, error in
                if error == nil, let image = image {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                        v.layer.borderColor = pinkColor.cgColor
                    }
                }
            })
        }
        imageView.isHidden = !needShowTitle
        
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(l)
        NSLayoutConstraint.activate([
            l.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
            l.leftAnchor.constraint(equalTo: v.rightAnchor, constant: 8)
        ])
        l.text = group.getTitle()
        l.isHidden = !needShowTitle
        
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(sv)
        sv.distribution = .fillEqually
        sv.axis = .horizontal
        sv.spacing = 4
        NSLayoutConstraint.activate([
            sv.topAnchor.constraint(equalTo: topView.topAnchor),
            sv.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 8),
            sv.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -8)
        ])

        progressViews = [ProgressView]()
        for i in 0 ..< stories.count {
            let storyData = stories[i].getStoryData()
            if self.activeOnly && storyData.status != "active" {
                continue
            }
            let pv = ProgressView(stories[i], with: i)
            progressViews.append(pv)
            pv.delegate = self
            sv.addArrangedSubview(pv)
        }
    }
    
    private func prepareStories() {
        pageContainer.delegate = self
        pageContainer.dataSource = self
        pages = [ShowStoryViewController]()
        for story in stories {
            let storyData = story.getStoryData()
            if self.activeOnly && storyData.status != "active" {
                continue
            }
            let vc = ShowStoryViewController(story, storyData: storyData)
            pages.append(vc)
        }
        pageContainer.view.frame = view.bounds
    }
}

//MARK: - Actions
extension StoriesViewController {
    @objc func closeTapped(_ sender: UIButton) {
        let reaction = WidgetReaction(story_id: stories[currentIndex].id,
                                      group_id: "",
                                      user_id: UserDefaults.standard.string(forKey: userIdKey) ?? "",
                                      widget_id: "",
                                      type: statisticCloseParam,
                                      value: "",
                                      locale: StorySDK.deviceLanguage)
        sendStatistics(reaction)
        
        _ = LazyImageLoader.shared.cancel()
        currentIndex = 0
        for pv in progressViews {
            pv.reset()
        }
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - PageViewController Delegate, Progress Delegate
extension StoriesViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource, ProgressDelegate {
    func progressFinished(story: Story, index: Int) {
        let time = self.progressViews[currentIndex].currentTime
//        print("Current time from progress:", time, "index:", currentIndex)
        if time > 2 {
            let reaction = WidgetReaction(story_id: story.id,
                                          group_id: story.group_id,
                                          user_id: UserDefaults.standard.string(forKey: userIdKey) ?? "",
                                          widget_id: "",
                                          type: statisticImpressionParam,
                                          value: "",
                                          locale: StorySDK.deviceLanguage)
            sendStatistics(reaction)
        }
        let reaction = WidgetReaction(story_id: story.id,
                                      group_id: story.group_id,
                                      user_id: UserDefaults.standard.string(forKey: userIdKey) ?? "",
                                      widget_id: "",
                                      type: statisticDurationParam,
                                      value: "\(time)",
                                      locale: StorySDK.deviceLanguage)
        sendStatistics(reaction)
        currentIndex = index + 1
        DispatchQueue.main.async {
            if self.currentIndex < self.stories.count {
                self.pageContainer.setViewControllers([self.pages[self.currentIndex]], direction: .forward, animated: true, completion: nil)
                self.progressViews[self.currentIndex].start()
            }
            else {
                _ = LazyImageLoader.shared.cancel()
                self.currentIndex = 0
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let current = self.pages.firstIndex(of: viewController as! ShowStoryViewController)
        if current == 0 {
            return nil
        }
        let previous = abs((current! - 1 + self.pages.count) % self.pages.count)
        
        return self.pages[previous]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let current = self.pages.firstIndex(of: viewController as! ShowStoryViewController)
        if current == self.pages.count - 1 {
            return nil
        }
        let next = abs((current! + 1) % self.pages.count)
        
        return self.pages[next]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        self.pendingIndex = self.pages.firstIndex(of: pendingViewControllers.first! as! ShowStoryViewController)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            let time = self.progressViews[currentIndex].currentTime
            let story = stories[currentIndex]
//            print("Current time:", time, "index:", currentIndex)
            if time > 2 {
                let reaction = WidgetReaction(story_id: story.id,
                                              group_id: story.group_id,
                                              user_id: UserDefaults.standard.string(forKey: userIdKey) ?? "",
                                              widget_id: "",
                                              type: statisticImpressionParam,
                                              value: "",
                                              locale: StorySDK.deviceLanguage)
                sendStatistics(reaction)
            }
            let reaction = WidgetReaction(story_id: story.id,
                                          group_id: story.group_id,
                                          user_id: UserDefaults.standard.string(forKey: userIdKey) ?? "",
                                          widget_id: "",
                                          type: statisticDurationParam,
                                          value: "\(time)",
                                          locale: StorySDK.deviceLanguage)
            sendStatistics(reaction)
            if let index = self.pendingIndex {
                if index > self.currentIndex {
                    self.progressViews[currentIndex].finish()
                }
                else if index < self.currentIndex {
                    self.progressViews[currentIndex].reset()
                }
                self.currentIndex = index
                self.progressViews[currentIndex].start()
            }
        }
    }
}

//MARK: - Notifications
extension StoriesViewController {
    func needSendStatistics(notification: Notification) {
        pageContainer.isPagingEnabled = true
        self.progressViews[currentIndex].resume()
        if let ui = notification.userInfo, let type = ui[widgetTypeParam] as? String, let group_id = ui[groupIdParam] as? String, let story_id = ui[storyIdParam] as? String, let widget_id = ui[widgetIdParam] as? String, let value = ui[widgetValueParam] as? String {
            let userID = UserDefaults.standard.string(forKey: userIdKey) ?? ""
            let reaction = WidgetReaction(story_id: story_id,
                                          group_id: group_id,
                                          user_id: userID,
                                          widget_id: widget_id,
                                          type: type,
                                          value: value,
                                          locale: StorySDK.deviceLanguage)
            sendStatistics(reaction)
        }
    }
    
    private func sendStatistics(_ reaction: WidgetReaction) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try! encoder.encode(reaction)
        let reactionString = String(data: jsonData, encoding: .utf8)!
        print(reactionString)
        StorySDK.sendStatistic(jsonData, completion: { error, dict, code in
            if let error = error {
                print(error.localizedDescription)
            }
        })
    }
    
    func disableSwipe(notification: Notification) {
        pageContainer.isPagingEnabled = false
        self.progressViews[currentIndex].pause()
    }

    func enableSwipe(notification: Notification) {
        pageContainer.isPagingEnabled = true
        self.progressViews[currentIndex].resume()
    }
    
    func startConfetti(notification: Notification) {
        disableSwipe(notification: notification)
        
        let v = ConfettiView(frame: view.frame)
        view.addSubview(v)
        v.startConfetti()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            v.stopConfetti()
            v.removeFromSuperview()
            self.pageContainer.isPagingEnabled = true
            self.progressViews[self.currentIndex].resume()
        }
    }
}
