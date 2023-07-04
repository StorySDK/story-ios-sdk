//
//  SRStoriesGestureRecognizer.swift
//  
//
//  Created by Aleksei Cherepanov on 20.06.2022.
//

import UIKit

final class SRStoriesGestureRecognizer: NSObject {
    var resignFirstResponder: (() -> Void)?
    
    weak var dataStorage: SRStoriesDataStorage?
    weak var widgetResponder: SRWidgetResponder?
    weak var progress: SRProgressController?
    
    @objc func swipeUp(_ gesture: SRSwipeUpGestureRecognizer) {
        guard let view = gesture.view else { return }
        let updateTransform: (CGFloat) -> Void = { [weak view] ty in
            UIView.animate(
                withDuration: SRConstants.animationsDuration,
                animations: { view?.transform.ty = ty }
            )
        }
        switch gesture.state {
        case .began:
            let transform = gesture.translation(in: view).y
            guard transform < 0 else { break }
            progress?.willBeginDragging()
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
            if isCancelled { progress?.didEndDragging() }
            updateTransform(0)
        case .possible:
            break
        case .failed, .cancelled:
            updateTransform(0)
            progress?.didEndDragging()
        @unknown default:
            break
        }
    }
    
    @objc func onTap(_ gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .possible, .changed:
            break
        case .began:
            progress?.willBeginDragging()
        case .ended:
            progress?.didEndDragging()
            let screenWidth = UIScreen.main.bounds.width
            let position = gesture.location(in: nil).x / screenWidth
            if position < 0.5 {
                progress?.scrollBack()
            } else {
                progress?.scrollNext()
            }
        case .cancelled, .failed:
            progress?.didEndDragging()
        @unknown default:
            break
        }
    }
}

final class SRSwipeUpGestureRecognizer: UIPanGestureRecognizer {
    let widget: SRSwipeUpWidget
    
    init(widget: SRSwipeUpWidget, target: SRStoriesGestureRecognizer?) {
        self.widget = widget
        super.init(target: target, action: #selector(SRStoriesGestureRecognizer.swipeUp))
    }
}
