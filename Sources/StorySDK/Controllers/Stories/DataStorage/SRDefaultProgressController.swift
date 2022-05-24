//
//  SRDefaultProgressController.swift
//  
//
//  Created by Aleksei Cherepanov on 21.05.2022.
//

import UIKit

final class SRDefaultProgressController: SRProgressController {
    var isDragging: Bool = false
    var isInteracted: Bool = false
    var timerPeriod: TimeInterval = 0.5
    var timeForStory: TimeInterval = 7
    var onProgressUpdated: ((Float) -> Void)?
    var onScrollToStory: ((Int) -> Void)?
    var onScrollCompeted: (() -> Void)?
    var numberOfItems: Int = 0
    var activeColor: UIColor?
    var progress: Float = 0 {
        didSet { onProgressUpdated?(progress) }
    }
    var timer: Timer? {
        didSet {
            oldValue?.invalidate()
            timer?.fire()
        }
    }
    
    init() {}
    
    func startAutoscrolling() {
        timer = .scheduledTimer(withTimeInterval: timerPeriod, repeats: true) { [weak self] _ in
            self?.onTimerUpdated()
        }
    }
    
    func startAutoscrollingAfter(_ deadline: DispatchTime) {
        DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
            self?.startAutoscrolling()
        }
    }
    
    public func pauseAutoscrolling() {
        timer = nil
    }
    
    public func pauseAutoscrollingUntil(_ deadline: DispatchTime) {
        pauseAutoscrolling()
        startAutoscrollingAfter(deadline)
    }
    
    public func willBeginDragging() {
        isDragging = true
    }
    
    public func didEndDragging() {
        isDragging = false
    }
    
    public func didScroll(offset: Float, contentWidth: Float) {
        guard isDragging else { return }
        progress = min(1, max(0, offset / contentWidth))
    }
    
    public func didInteract() {
        
    }
    
    public func setupProgress(_ component: SRProgressComponent) {
        component.numberOfItems = numberOfItems
        component.animationDuration = timerPeriod
        activeColor.map { component.activeColor = $0 }
    }
    
    func onTimerUpdated() {
        guard !isDragging && !isInteracted else { return }
        guard progress < 1 else { return }
        guard numberOfItems > 0 else { return }
        let storyProgress = 1 / Float(numberOfItems)
        let oldIndex = floor(progress / storyProgress)
        let totalTime = TimeInterval(numberOfItems) * timeForStory
        let progressForOneFire = Float(timerPeriod / totalTime)
        let newProgress = progress + progressForOneFire
        if newProgress >= 1 {
            progress = 1
            onScrollCompeted?()
            return
        } else {
            let newIndex = floor(newProgress / storyProgress)
            if newIndex - oldIndex > .ulpOfOne {
                onScrollToStory?(Int(newIndex))
            }
            progress = newProgress
        }
    }
}
