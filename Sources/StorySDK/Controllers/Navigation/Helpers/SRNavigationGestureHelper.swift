//
//  SRNavigationGestureHelper.swift
//  
//
//  Created by Aleksei Cherepanov on 25.06.2022.
//

import UIKit

final class SRNavigationGestureHelper: NSObject, UIGestureRecognizerDelegate {
    let animations = SRNavigationAnimationHelper()
    var dataSource: SRNavigationViewDataSource? {
        get { animations.dataSource }
        set { animations.dataSource = newValue }
    }
    let dismiss = UIPanGestureRecognizer()
    let swipe = UIPanGestureRecognizer()
    
    override init() {
        super.init()
        dismiss.delegate = self
        swipe.delegate = self
        dismiss.addTarget(self, action: #selector(onPanToDismiss))
        swipe.addTarget(self, action: #selector(onPanToSwipe))
    }
    
    @objc func onPanToDismiss(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            animations.dismiss = animations.makeDismissAnimator(duration: .animationsDuration)
            animations.dismiss?.pauseAnimation()
        case .ended:
            guard let animator = animations.dismiss else { return }
            if animator.fractionComplete < 1 { animator.isReversed = true }
            animator.startAnimation()
        case .changed:
            animations.dismiss?.pauseAnimation()
            let transition = gesture.translation(in: nil).y
            animations.dismiss?.fractionComplete = min(1, transition / 200)
        case .cancelled, .failed:
            animations.dismiss?.startAnimation()
        case .possible:
            break
        @unknown default:
            break
        }
    }
    
    @objc func onPanToSwipe(_ gesture: UIPanGestureRecognizer) {
        guard let dataSource = dataSource else { return }
        switch gesture.state {
        case .began:
            let velocity = gesture.velocity(in: nil).x
            let nextIndex = velocity < 0 ? dataSource.currentIndex + 1 : dataSource.currentIndex - 1
            animations.swipe = animations.makeSwipeAnimator(duration: .animationsDuration, to: nextIndex)
            animations.swipe?.pauseAnimation()
        case .ended:
            guard let animator = animations.swipe else { return }
            let transition = abs(gesture.translation(in: nil).x)
            let swipeLength = dataSource.mainView.bounds.width / 3
            if transition / swipeLength < 1 { animator.isReversed = true }
            animator.startAnimation()
        case .changed:
            animations.swipe?.pauseAnimation()
            let transition = gesture.translation(in: nil).x
            let swipeLength = dataSource.mainView.bounds.width
            animations.swipe?.fractionComplete = min(1, abs(transition / swipeLength))
        case .cancelled, .failed:
            animations.swipe?.startAnimation()
        case .possible:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        let velocity = panGesture.velocity(in: nil)
        switch panGesture {
        case dismiss:
            return abs(velocity.y) > abs(velocity.x)
        case swipe:
            guard abs(velocity.y) < abs(velocity.x) else { return false }
            guard let dataSource = dataSource else { return false }
            if velocity.x > 0 {
                return dataSource.currentIndex > 0
            } else {
                return dataSource.currentIndex < dataSource.numberOfGroups - 1
            }
        default:
            return true
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var view = touch.view
        while(view != nil) {
            guard let v = view else { return false }
            if v.isKind(of: SRInteractiveWidgetView.self) { return false }
            if v.isKind(of: SRStoriesView.self) { return true }
            view = v.superview
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
