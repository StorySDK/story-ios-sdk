//
//  ProgressView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

protocol ProgressDelegate: AnyObject {
    func progressFinished(story: Story, index: Int)
}

final class ProgressView: UIProgressView {
    weak var delegate: ProgressDelegate?
    
    private let story: Story
    private let index: Int
    private let storyDuration: TimeInterval
    
    /// Timer
    private var timer: Timer?
    /// Интервал таймера
    private var timeDelta: TimeInterval = 0.05
    /// Текущее значение таймера
    var currentTime: TimeInterval = 0.0
    
    init(_ story: Story, with index: Int, duration: TimeInterval) {
        self.story = story
        self.index = index
        self.storyDuration = duration
        super.init(frame: .zero)
        self.progress = 0.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start() {
        progress = 0
        currentTime = 0
        startTimer()
    }
    
    func finish() {
        progress = 1
        currentTime = storyDuration
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        progress = 0
        currentTime = 0
        timer?.invalidate()
        timer = nil
    }

    func resume() {
        startTimer()
    }
    
    func pause() {
        timer?.invalidate()
    }
}

// MARK: - Timer
extension ProgressView {
    private func startTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: timeDelta,
            target: self,
            selector: #selector(update),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc private func update () {
        if currentTime < storyDuration {
            currentTime += timeDelta
            let progress = currentTime / storyDuration
            self.setProgress(Float(progress), animated: true)
        } else {
            guard self.timer != nil else { return }
            timer?.invalidate()
            timer = nil
            delegate?.progressFinished(story: story, index: index)
        }
    }
}
