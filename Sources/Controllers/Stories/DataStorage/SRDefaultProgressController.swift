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
        var onProgressUpdated: ((Float) -> Void)?
        var onScrollToStory: ((Int, Bool) -> Void)?
        var onScrollCompleted: (() -> Void)?
        var numberOfItems: Int = 0
        var totalDuration: TimeInterval = .zero
        var durations: [TimeInterval] = []
        var activeColor: StoryColor?
        var progress: Float = 0 {
            didSet { onProgressUpdated?(progress) }
        }
        var elapsedTime: TimeInterval = .zero
        var enabledScroll: Bool = true
        
        func durationsEdges(n: Int) -> TimeInterval {
            guard n >= 0 else { return .zero }
            var partSum: TimeInterval = .zero
            
            for index in 0...n {
                partSum += durations[index]
            }
            
            return partSum
        }
        
        func indexOfStoryByDuration(value: TimeInterval) -> Int {
            for index in 0..<numberOfItems {
                if value < durationsEdges(n: index) {
                    return index
                }
            }
            
            return numberOfItems-1
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
            guard enabledScroll else { return }
            guard contentWidth > 0 else { return }
            guard numberOfItems > 0 else { return }
            let index = Int(offset / (contentWidth / Float(numberOfItems)))
            let currentIndex = indexOfStoryByDuration(value: elapsedTime)
            
            guard isDragging else { return }
            
            if index != currentIndex {
                enabledScroll = false
                
                if index > currentIndex {
                    if index >= numberOfItems {
                        return
                    }
                    
                    scrollNext(index: currentIndex + 1)
                } else {
                    scrollBack(index: max(currentIndex - 1, 0))
                }
            }
        }
        
        func setupProgress(_ component: SRProgressComponent) {
            component.totalDuration = totalDuration
            component.durations = durations
            component.numberOfItems = numberOfItems
            component.animationDuration = timerPeriod
            activeColor.map { component.activeColor = $0 }
        }
        
        func onTimerUpdated() {
            guard !isDragging && !isInteracted && !isTransiting else { return }
            if !isLoading.isEmpty, !isLoading.allSatisfy({ $0.value }) { return }
            guard progress < 1 else { return }
            guard numberOfItems > 0 else { return }
            
            let storyProgressInSecs = totalDuration
            
            let oldIndex = indexOfStoryByDuration(value: elapsedTime)
            
            let totalTime = totalDuration
            
            let progressForOneFire = Float(timerPeriod / totalTime)
            
            elapsedTime += timerPeriod
            enabledScroll = true
            
            let nProgress = elapsedTime / storyProgressInSecs
            let nIndex = indexOfStoryByDuration(value: elapsedTime)
            
            if nProgress >= 1 {
                progress = 1
                onScrollCompleted?()
                return
            } else {
                if nIndex - oldIndex > 0 {
                    onScrollToStory?(nIndex, false)
                }
                
                progress = Float(nProgress)
            }
        }
        
        @objc func didEnterBackground() {
            pauseAutoscrolling()
        }
        
        @objc func willEnterForeground() {
            startAutoscrolling()
        }
        
        func scrollNext(index: Int) {
            let currentIndex = indexOfStoryByDuration(value: elapsedTime)
            guard index != currentIndex else { return }
            
            scrollNext()
        }
        
        func scrollBack(index: Int) {
            let currentIndex = indexOfStoryByDuration(value: elapsedTime)
            guard index != currentIndex else { return }
            
            scrollBack()
        }
        
        func scrollNext() {
            let currentIndex = indexOfStoryByDuration(value: elapsedTime)
            var index = currentIndex
            if index + 1 < numberOfItems {
                index += 1
                progress = Float( durationsEdges(n: currentIndex) / totalDuration)
                elapsedTime = durationsEdges(n: currentIndex)
                analytics?.storyDidChanged(to: index, byUser: true)
                
                if index + 1 == numberOfItems { // final story
                    analytics?.reportQuizFinish(time: Date())
                }
                
                onScrollToStory?(index, true)
            } else {
                onScrollCompleted?()
            }
        }
        
        func scrollBack() {
            let currentIndex = indexOfStoryByDuration(value: elapsedTime)
            var index = currentIndex
            if index - 1 >= 0 {
                index -= 1
                progress = Float(durationsEdges(n: index - 1) / totalDuration)
                elapsedTime = durationsEdges(n: index - 1)
                
                analytics?.storyDidChanged(to: index, byUser: true)
                onScrollToStory?(index, false)
            }
        }
    }
#endif
