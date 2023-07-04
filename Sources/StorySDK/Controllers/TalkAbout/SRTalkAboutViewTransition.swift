//
//  SRTalkAboutViewTransition.swift
//  
//
//  Created by Aleksei Cherepanov on 27.06.2022.
//

import UIKit

final class SRTalkAboutViewTransition: NSObject, UIViewControllerAnimatedTransitioning {
    weak var sourceWidget: SRTalkAboutView?
    
    init(widget: SRTalkAboutView?) {
        self.sourceWidget = widget
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        SRConstants.animationsDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let vc = transitionContext.viewController(forKey: .to) as? SRTalkAboutViewController {
            present(transitionContext: transitionContext, vc: vc)
        } else if let vc = transitionContext.viewController(forKey: .from) as? SRTalkAboutViewController {
            dismiss(transitionContext: transitionContext, vc: vc)
        } else {
            transitionContext.completeTransition(true)
        }
    }
    
    func present(transitionContext: UIViewControllerContextTransitioning, vc: SRTalkAboutViewController) {
        guard let fromWidget = sourceWidget else {
            transitionContext.completeTransition(true)
            return
        }
        vc.view.frame = UIScreen.main.bounds
        vc.view.layoutIfNeeded()
        
        let containerView = transitionContext.containerView
        containerView.addSubview(vc.view)
        
        guard let toWidgetSnapshot = vc.widget.snapshotView(afterScreenUpdates: true) else {
            transitionContext.completeTransition(true)
            return
        }
        let toBackgroundSnapshot = UIVisualEffectView(effect: nil)
        toBackgroundSnapshot.frame = vc.background.frame
        let targetEffect = vc.background.effect
        
        fromWidget.alpha = 0
        vc.view.alpha = 0
        let fromTransition = fromWidget.transform
        fromWidget.transform = .identity
        let fromFrame = fromWidget.convert(fromWidget.bounds, to: vc.view)
        
        toWidgetSnapshot.frame = fromFrame
        toWidgetSnapshot.transform = fromTransition
        
        let targetFrame = vc.widget.frame
        let targetTransform = CGAffineTransform.identity
            .translatedBy(x: targetFrame.midX - fromFrame.midX,
                          y: targetFrame.midY - fromFrame.midY)
            .scaledBy(x: targetFrame.width / fromFrame.width,
                      y: targetFrame.height / fromFrame.height)
        
        fromWidget.transform = fromTransition
        
        [toBackgroundSnapshot, toWidgetSnapshot].forEach(containerView.addSubview)
        
        let animator = UIViewPropertyAnimator(
            duration: transitionDuration(using: transitionContext),
            curve: .easeOut
        )
        animator.addAnimations {
            toBackgroundSnapshot.effect = targetEffect
            toWidgetSnapshot.transform = targetTransform
        }
        animator.addCompletion { _ in
            vc.view.alpha = 1
            toBackgroundSnapshot.removeFromSuperview()
            toWidgetSnapshot.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
        animator.startAnimation()
    }
    
    func dismiss(transitionContext: UIViewControllerContextTransitioning, vc: SRTalkAboutViewController) {
        guard let toWidget = sourceWidget else {
            transitionContext.completeTransition(true)
            return
        }
        
        vc.updateWidgetFrame()
        let fromBackground = vc.background
        let fromWidget = vc.widget
        
        guard let fromWidgetSnapshot = vc.widget.snapshotView(afterScreenUpdates: true) else {
            transitionContext.completeTransition(true)
            return
        }
        let containerView = transitionContext.containerView
        fromWidget.alpha = 0
        let fromFrame = fromWidget.frame
        fromWidgetSnapshot.frame = fromFrame
        containerView.addSubview(fromWidgetSnapshot)
        
        let toTransform = toWidget.transform
        
        toWidget.transform = .identity
        let targetFrame = toWidget.convert(toWidget.bounds, to: vc.view)
        let targetTransform = CGAffineTransform.identity
            .translatedBy(x: targetFrame.midX - fromFrame.midX,
                          y: targetFrame.midY - fromFrame.midY)
            .rotated(by: toTransform.angle)
        toWidget.transform = toTransform
        
        let animator = UIViewPropertyAnimator(
            duration: transitionDuration(using: transitionContext),
            curve: .easeIn
        )
        animator.addAnimations {
            fromBackground.effect = nil
            fromWidgetSnapshot.transform = targetTransform
        }
        animator.addCompletion { _ in
            toWidget.alpha = 1
            fromWidget.alpha = 1
            fromWidgetSnapshot.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
        animator.startAnimation()
    }
}

final class SRTalkAboutViewTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    weak var sourceWidget: SRTalkAboutView?
    
    init(widget: SRTalkAboutView) {
        self.sourceWidget = widget
        super.init()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        SRTalkAboutViewTransition(widget: sourceWidget)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        SRTalkAboutViewTransition(widget: sourceWidget)
    }
}

private extension CGAffineTransform {
    var angle: CGFloat { atan2(b, a) }
}
