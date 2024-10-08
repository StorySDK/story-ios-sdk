//
//  SRNavigationAnimationHelper.swift
//  
//
//  Created by Aleksei Cherepanov on 25.06.2022.
//

#if os(macOS)
    import Cocoa

    final class SRNavigationAnimationHelper {
    }
#elseif os(iOS)
    import UIKit

    final class SRNavigationAnimationHelper {
        weak var dataSource: SRNavigationViewDataSource?
        var dismiss: UIViewPropertyAnimator?
        var swipe: UIViewPropertyAnimator?
        
        func makeDismissAnimator(duration: TimeInterval) -> UIViewPropertyAnimator {
            let animator = UIViewPropertyAnimator(
                duration: duration,
                curve: .easeOut
            )
            
            guard let dataSource = dataSource else { return animator }
            let currentIndex = dataSource.currentIndex
            let current = dataSource.loadViewController(currentIndex)
            let height = dataSource.containerView.frame.height ?? UIScreen.main.bounds.height
            
            animator.addAnimations { [weak dataSource] in
                UIView.animateKeyframes(
                    withDuration: duration,
                    delay: 0.0,
                    options: .calculationModeCubic,
                    animations: {
                        UIView.addKeyframe(
                            withRelativeStartTime: 0.0,
                            relativeDuration: 1.0,
                            animations: { dataSource?.mainView.transform =
                                CGAffineTransform(translationX: 0, y: max(0, height / 3))
                                    .scaledBy(x: 0.9, y: 0.9)
                            }
                        )
                    }
                )
            }
            animator.addCompletion { [weak dataSource] position in
                defer { current.didEndTransition() }
                guard case .end = position else { return }
                dataSource?.setNeedDismiss(false)
            }
            current.willBeginTransition()
            return animator
        }
        
        func makeSwipeAnimator(duration: TimeInterval, to index: Int, byUser: Bool) -> UIViewPropertyAnimator {
            let animator = UIViewPropertyAnimator(
                duration: duration,
                curve: .easeInOut
            )
            guard let dataSource = dataSource else { return animator }

            let currentIndex = dataSource.currentIndex
            let current = dataSource.loadViewController(currentIndex)
            let next = dataSource.loadViewController(index)
            dataSource.addViewController(next)
            
            let offset = current.view.frame.width / 2
            current.view.layer.anchorPointZ = offset
            next.view.layer.anchorPointZ = offset
            
            var initialTransform = CATransform3DIdentity
            initialTransform.m34 = 1 / 2000
            initialTransform = CATransform3DTranslate(
                initialTransform,
                0, 0, offset
            )
            
            var transform = initialTransform
            var angle: CGFloat = .pi / 2
            if index > currentIndex { angle *= -1 }
            transform = CATransform3DRotate(
                transform,
                angle,
                0, 1, 0
            )
            next.view.layer.transform = transform
            current.view.layer.transform = initialTransform
            current.view.alpha = 1
            next.view.alpha = 0
            
            animator.addAnimations {
                var transform = initialTransform
                transform = CATransform3DRotate(
                    transform,
                    -angle,
                    0, 1, 0
                )
                current.view.layer.transform = transform
                next.view.layer.transform = initialTransform
                current.view.alpha = 0
                next.view.alpha = 1
            }
            animator.addCompletion { [weak dataSource] position in
                switch position {
                case .end:
                    if byUser {
                        if currentIndex > index {
                            current.reportSwipeForward()
                        } else {
                            current.reportSwipeBackward()
                        }
                    }
                    dataSource?.removeViewController(current)
                    dataSource?.currentIndex = index
                case .current, .start:
                    dataSource?.removeViewController(next)
                @unknown default:
                    dataSource?.removeViewController(next)
                }
                current.didEndTransition()
                next.didEndTransition()
            }
            current.willBeginTransition()
            next.willBeginTransition()
            return animator
        }
    }
#endif

protocol SRNavigationViewDataSource: AnyObject {
    /// Contains all children View Controllers
    var containerView: StoryView { get }
    /// Main view of the navigation view controller
    var mainView: StoryView { get }
    /// Presented group index
    var currentIndex: Int { get set }
    /// Number of groups in navigation controller
    var numberOfGroups: Int { get }
    /// Returns story view controller with a group by index
    func loadViewController(_ index: Int) -> SRStoriesViewController
    /// Adds new child view controller
    func addViewController(_ vc: StoryViewController)
    /// Removes child view controller from parent
    func removeViewController(_ vc: StoryViewController)
    /// Calls whent the navigation controller should be desmissed
    func setNeedDismiss(_ animated: Bool)
}
