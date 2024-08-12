//
//  SRNavigationController.swift
//  
//
//  Created by Aleksei Cherepanov on 22.06.2022.
//

#if os(macOS)
    import Cocoa

    public final class SRNavigationController {
        public init(index: Int, groups: [SRStoryGroup], sdk: StorySDK = .shared) throws {
            throw SRError.notImplementedmacOS
        }
    }
#elseif os(iOS)
    import UIKit

public final class SRNavigationController: UIViewController, SRNavigationViewDataSource {
        private let groups: [SRStoryGroup]
        private let sdk: StorySDK
        private let backgroundColor: UIColor
        private var loadedViewControllers: [Int: SRStoriesViewController] = [:]
        private let gestures = SRNavigationGestureHelper()
        private var animations: SRNavigationAnimationHelper { gestures.animations }
        
        public override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
        var mainView: UIView { view }
        let containerView = UIView()
        var currentIndex: Int
        var numberOfGroups: Int { groups.count }
        
        public init(index: Int, groups: [SRStoryGroup], sdk: StorySDK = .shared,
                    backgroundColor: UIColor = UIColor.black) {
            self.groups = groups
            self.currentIndex = index
            self.sdk = sdk
            self.backgroundColor = backgroundColor
            
            super.init(nibName: nil, bundle: nil)
            modalPresentationStyle = .overFullScreen
            modalPresentationCapturesStatusBarAppearance = true
        }
        
        convenience init(group: SRStoryGroup, sdk: StorySDK = .shared) {
            self.init(index: 0, groups: [group], sdk: sdk)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = backgroundColor
            
            gestures.dataSource = self
            setupContainer()
            addGestures()
            loadCurrentViewController()
        }
        
        public override func viewDidLayoutSubviews() {
            var frame = view.bounds.inset(by: view.safeAreaInsets)
            let maxHeight = frame.height
            
            if sdk.configuration.needShowTitle {
                frame.size.height = min(maxHeight, frame.height + 64)
            }
            containerView.frame = frame
            super.viewDidLayoutSubviews()
        }
        
        private func setupContainer() {
            view.addSubview(containerView)
        }
        
        private func addGestures() {
            [gestures.dismiss, gestures.swipe].forEach(view.addGestureRecognizer)
        }
        
        private func loadCurrentViewController() {
            let vc = loadViewController(currentIndex)
            addStoriesViewController(vc)
        }
        
        func loadViewController(_ index: Int) -> SRStoriesViewController {
            if let loaded = loadedViewControllers[index] { return loaded }
            let vc = SRStoriesViewController(groups[index], sdk: sdk)
            vc.view.backgroundColor = .clear
            vc.isScrollEnabled = false
            if index < groups.count - 1 {
                let scrollNext: () -> Void = { [weak animations] in
                    guard let animations = animations else { return }
                    let animation = animations.makeSwipeAnimator(
                        duration: SRConstants.groupTransitionAnimationDuration,
                        to: index + 1,
                        byUser: false
                    )
                    animation.startAnimation()
                }
                vc.updateOnScrollCompleted(scrollNext)
                vc.updateOnGotEmptyGroup(scrollNext)
            }
            loadedViewControllers[index] = vc
            return vc
        }
        
        func addStoriesViewController(_ vc: SRStoriesViewController?) {
            guard let vc = vc else { return }
            
            addChild(vc)
            containerView.addSubview(vc.view)
            vc.didMove(toParent: self)
            
            containerView.bounds = CGRect(origin: .zero,
                                          size: vc.groupSize())
            vc.view.frame = containerView.bounds
            
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                vc.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                vc.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                vc.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                vc.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            ])
        }
    
        func addViewController(_ vc: UIViewController) {
            addStoriesViewController(vc as? SRStoriesViewController)
        }
        
        func removeViewController(_ vc: UIViewController) {
            vc.didMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
        
        func setNeedDismiss(_ animated: Bool) {
            dismiss(animated: animated)
        }
    }
#endif
