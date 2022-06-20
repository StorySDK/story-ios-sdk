//
//  SRStoriesGestureRecognizer.swift
//  
//
//  Created by Aleksei Cherepanov on 20.06.2022.
//

import UIKit

final class SRStoriesGestureRecognizer: NSObject {
    var onUpdateTransformNeeded: ((Float) -> Void)? {
        widgetResponder?.onUpdateTransformNeeded
    }
    var dismiss: (() -> Void)? {
        dataStorage?.dismiss
    }
    var resignFirstResponder: (() -> Void)?
    weak var dataStorage: SRStoriesDataStorage?
    weak var widgetResponder: SRWidgetResponder?
    weak var progress: SRProgressController?
    
    @objc func swipeDown(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            let transform = Float(gesture.translation(in: gesture.view).y)
            guard transform > 0 else { break }
            progress?.pauseAutoscrolling()
            resignFirstResponder?()
            onUpdateTransformNeeded?(transform)
        case .changed:
            var transform = Float(gesture.translation(in: gesture.view).y)
            transform = max(transform, 0)
            onUpdateTransformNeeded?(transform)
        case .ended:
            let transform = Float(gesture.translation(in: gesture.view).y)
            if transform > 200 {
                dismiss?()
            } else {
                onUpdateTransformNeeded?(0)
                progress?.startAutoscrolling()
            }
        case .possible:
            break
        case .failed, .cancelled:
            onUpdateTransformNeeded?(0)
            progress?.startAutoscrolling()
        @unknown default:
            break
        }
    }
    
    @objc func swipeUp(_ gesture: SRSwipeUpGestureRecognizer) {
        guard let view = gesture.view else { return }
        let updateTransform: (CGFloat) -> Void = { [weak view] ty in
            UIView.animate(
                withDuration: .animationsDuration,
                animations: { view?.transform.ty = ty }
            )
        }
        switch gesture.state {
        case .began:
            let transform = gesture.translation(in: view).y
            guard transform < 0 else { break }
            progress?.pauseAutoscrolling()
            resignFirstResponder?()
            updateTransform(transform)
        case .changed:
            var transform = gesture.translation(in: view).y
            transform = min(transform, 0)
            updateTransform(transform)
        case .ended:
            let transform = gesture.translation(in: view).y
            var isCancelled = true
            if transform < -100, let widget = gesture.view as? SRSwipeUpView {
                isCancelled = !(widgetResponder?.didSwipeUp(widget) ?? false)
            }
            if isCancelled { progress?.startAutoscrolling() }
            updateTransform(0)
        case .possible:
            break
        case .failed, .cancelled:
            updateTransform(0)
            progress?.startAutoscrolling()
        @unknown default:
            break
        }
    }
}

class SRSwipeUpGestureRecognizer: UIPanGestureRecognizer {
    let widget: SRSwipeUpWidget
    
    init(widget: SRSwipeUpWidget, target: SRStoriesGestureRecognizer?) {
        self.widget = widget
        super.init(target: target, action: #selector(SRStoriesGestureRecognizer.swipeUp))
    }
}
