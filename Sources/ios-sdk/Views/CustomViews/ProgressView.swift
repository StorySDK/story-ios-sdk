//
//  ProgressView.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

protocol ProgressDelegate: AnyObject {
    func progressFinished(story: Story, index: Int)
}

final class ProgressView: UIProgressView {
    weak var delegate: ProgressDelegate?
    
    private var story: Story!
    private var index: Int!
    
    ///Timer
    private var timer: Timer?
    ///Интервал таймера
    private var timeDelta: TimeInterval = 0.05
    ///Текущее значение таймера
    var currentTime: TimeInterval = 0.0
    
    convenience init(_ story: Story, with index: Int) {
        self.init()
        self.story = story
        self.index = index
        self.tintColor = progressColor
        self.progress = 0.0
    }
    
    func start() {
        progress = 0
        currentTime = 0
        startTimer()
    }
    
    func finish() {
        progress = 1
        currentTime = progressDuration
        if self.timer != nil {
            self.timer!.invalidate()
            self.timer = nil
        }
    }
    
    func reset() {
        progress = 0
        currentTime = 0
        if self.timer != nil {
            self.timer!.invalidate()
            self.timer = nil
        }
    }

    func resume() {
        startTimer()
    }
    
    func pause() {
        if let timer = timer {
            timer.invalidate()
        }
    }
}

//MARK: - Timer
extension ProgressView {
    private func startTimer() -> Void {
        self.timer = Timer.scheduledTimer(timeInterval: self.timeDelta, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc private func update () {
        if self.currentTime < progressDuration {
            self.currentTime += self.timeDelta
            let progress = self.currentTime / progressDuration
            self.setProgress(Float(progress), animated: true)
        }
        else {
            if self.timer != nil {
                self.timer!.invalidate()
                self.timer = nil
                delegate?.progressFinished(story: story, index: index)
            }
        }
    }
}
