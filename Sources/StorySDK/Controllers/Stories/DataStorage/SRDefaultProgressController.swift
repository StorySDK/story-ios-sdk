//
//  SRDefaultProgressController.swift
//  
//
//  Created by Aleksei Cherepanov on 21.05.2022.
//

#if os(macOS)
    import Cocoa

    final class SRDefaultProgressController: NSObject {
        
        override init() {
            super.init()
        }
    }
#elseif os(iOS)
    import UIKit

    final class SRDefaultProgressController: NSObject, SRProgressController {
        var analytics: SRAnalyticsController?
        var isDragging: Bool = false
        var isInteracted: Bool = false
        var isLoading: [String: Bool] = [:]
        var timerPeriod: TimeInterval = 0.5
        var timeForStory: TimeInterval = 7
        var onProgressUpdated: ((Float) -> Void)?
        var onScrollToStory: ((Int, Bool) -> Void)?
        var onScrollCompleted: (() -> Void)?
        var numberOfItems: Int = 0
        var activeColor: StoryColor?
        var progress: Float = 0 {
            didSet { onProgressUpdated?(progress) }
        }
        /// The view controller is being transited
        var isTransiting: Bool = false
        var timer: Timer? {
            didSet {
                oldValue?.invalidate()
                timer?.fire()
            }
        }
        
        override init() {
            super.init()
            addEvents()
        }
        
        func addEvents() {
            NotificationCenter.default
                .addObserver(self,
                             selector: #selector(didEnterBackground),
                             name: UIApplication.didEnterBackgroundNotification,
                             object: nil)
            NotificationCenter.default
                .addObserver(self,
                             selector: #selector(willEnterForeground),
                             name: UIApplication.willEnterForegroundNotification,
                             object: nil)
        }
        
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
        
        func willBeginDragging() {
            isDragging = true
        }
        
        func didEndDragging() {
            isDragging = false
        }
        
        func willBeginTransition() {
            isTransiting = true
        }
        
        func didEndTransition() {
            isTransiting = false
        }
        
        func didScroll(offset: Float, contentWidth: Float) {
            guard contentWidth > 0 else { return }
            guard numberOfItems > 0 else { return }
            let index = Int(offset / (contentWidth / Float(numberOfItems)))
            analytics?.storyDidChanged(to: index, byUser: isDragging)
            guard isDragging else { return }
            progress = min(1, max(0, offset / contentWidth))
        }
        
        func setupProgress(_ component: SRProgressComponent) {
            component.numberOfItems = numberOfItems
            component.animationDuration = timerPeriod
            activeColor.map { component.activeColor = $0 }
        }
        
        func onTimerUpdated() {
            guard !isDragging && !isInteracted && !isTransiting else { return }
            if !isLoading.isEmpty, !isLoading.allSatisfy({ $0.value }) { return }
            guard progress < 1 else { return }
            guard numberOfItems > 0 else { return }
            let storyProgress = 1 / Float(numberOfItems)
            let oldIndex = floor(progress / storyProgress)
            let totalTime = TimeInterval(numberOfItems) * timeForStory
            let progressForOneFire = Float(timerPeriod / totalTime)
            let newProgress = progress + progressForOneFire
            if newProgress >= 1 {
                progress = 1
                onScrollCompleted?()
                return
            } else {
                let newIndex = floor(newProgress / storyProgress)
                if newIndex - oldIndex > .ulpOfOne {
                    onScrollToStory?(Int(newIndex), false)
                }
                progress = newProgress
            }
        }
        
        @objc func didEnterBackground() {
            pauseAutoscrolling()
        }
        
        @objc func willEnterForeground() {
            startAutoscrolling()
        }
        
        func scrollNext() {
            let storyProgress = 1 / Float(numberOfItems)
            var index = Int(floor(progress / storyProgress))
            if index + 1 < numberOfItems {
                index += 1
                progress = Float(index) / Float(numberOfItems)
                analytics?.storyDidChanged(to: index, byUser: true)
                
                if index + 1 == numberOfItems { // final story
                    analytics?.reportQuizFinish(time: Date())
                }
                
                onScrollToStory?(index, false)
            } else {
                onScrollCompleted?()
            }
        }
        
        func scrollBack() {
            let storyProgress = 1 / Float(numberOfItems)
            var index = Int(floor(progress / storyProgress))
            index -= 1
            guard index >= 0 else { return }
            progress = Float(index) / Float(numberOfItems)
            analytics?.storyDidChanged(to: index, byUser: true)
            onScrollToStory?(index, false)
        }
    }
#endif
