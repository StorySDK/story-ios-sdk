//
//  SRDefaultWidgetResponder.swift
//  
//
//  Created by Aleksei Cherepanov on 24.05.2022.
//

import UIKit

final class SRDefaultWidgetResponder: NSObject, SRWidgetResponder {
    let storySdk: StorySDK
    var containerFrame: SRRect = .zero
    var presentTalkAbout: ((SRTalkAboutViewController) -> Void)?
    var pauseInterval: DispatchTimeInterval = .seconds(1)
    weak var progress: SRProgressController?
    weak var analytics: SRAnalyticsController?
    private var transition: SRTalkAboutViewTransitionDelegate?
    
    private var isStarted: Bool = false
    
    init(sdk: StorySDK = .shared) {
        storySdk = sdk
        super.init()
    }
    
    // MARK: - SRTalkAboutViewDelegate
    
    func needShowKeyboard(_ widget: SRTalkAboutView) {
        widget.endEditing(true)
        let vc = SRTalkAboutViewController(
            story: widget.story,
            data: widget.data,
            talkAboutWidget: widget.talkAboutWidget,
            loader: widget.loader
        ) { [weak self] text in
            defer { self?.progress?.startAutoscrolling() }
            guard let text = text, !text.isEmpty else { return }
            widget.setupWidget(reaction: text)
            let request = SRStatistic(type: .answer, value: text)
            self?.analytics?.sendWidgetReaction(request, widget: widget)
            
        }
        transition = .init(widget: widget)
        vc.transitioningDelegate = transition
        progress?.pauseAutoscrolling()
        presentTalkAbout?(vc)
    }
    
    // MARK: - ChooseAnswerViewDelegate
    
    func didChooseAnswer(_ widget: ChooseAnswerView, answer: String, score: SRScore?) {
        let request = SRStatistic(type: .answer, value: answer)
        analytics?.sendWidgetReaction(request, widget: widget)
        progress?.pauseAutoscrollingUntil(.now() + pauseInterval)
        
        if !isStarted {
            isStarted = true
            analytics?.reportQuizStart(time: Date())
        }
        
        if let score = score {
            analytics?.dataStorage?.totalScore += Int(score.points ?? "0") ?? 0
        }
        
        guard answer == widget.chooseAnswerWidget.correct else { return }
        guard let canvas = widget.superview?.superview as? SRStoryCanvasView else { return }
        canvas.startConfetti()
    }
    
    // MARK: - EmojiReactionViewDelegate
    
    func didChooseEmojiReaction(_ widget: EmojiReactionView, emoji: String) {
        let request = SRStatistic(type: .answer, value: emoji)
        analytics?.sendWidgetReaction(request, widget: widget)
        progress?.pauseAutoscrollingUntil(.now() + pauseInterval)
    }
    
    // MARK: - QuestionViewDelegate
    
    func didChooseQuestionAnswer(_ widget: QuestionView, isYes: Bool) {
        let request = SRStatistic(type: .answer, value: isYes.questionWidgetString)
        analytics?.sendWidgetReaction(request, widget: widget)
        progress?.pauseAutoscrollingUntil(.now() + pauseInterval)
    }
    
    // MARK: - QuizMultipleAnswerViewDelegate
    
    func didChooseMultipleAnswer(_ widget: QuizMultipleAnswerView, answer: String, score: SRScore?) {
        let request = SRStatistic(type: .answer, value: answer)
        analytics?.sendWidgetReaction(request, widget: widget)
        
        if let score = score {
            analytics?.dataStorage?.totalScore += Int(score.points ?? "0") ?? 0
        }
    }
    
    func didChooseOneAnswer(score: SRScore?) {
        guard let score = score else { return }
        
        analytics?.dataStorage?.totalScore += Int(score.points ?? "0") ?? 0
        progress?.pauseAutoscrollingUntil(.now() + pauseInterval)
    }
    
    // MARK: - QuizMultipleImageViewDelegate
    
    // MARK: - SliderViewDelegate
    
    func didChooseSliderValue(_ widget: SliderView, value: Float) {
        let request = SRStatistic(type: .answer, value: "\(Int(value * 100))")
        analytics?.sendWidgetReaction(request, widget: widget)
    }
    
    func didStartSlide() {
        progress?.pauseAutoscrolling()
    }
    
    func didFinishSlide() {
        progress?.pauseAutoscrollingUntil(.now() + pauseInterval)
    }
    
    // MARK: - SRClickMeViewDelegate
    
    func didClickedButton(_ widget: SRClickMeView) {
        let request = SRStatistic(type: .click, value: widget.clickMeWidget.url)
        analytics?.sendWidgetReaction(request, widget: widget)
        
        guard let url = URL(string: widget.clickMeWidget.url) else { return }
        guard UIApplication.shared.canOpenURL(url) else { return }
        progress?.pauseAutoscrolling()
        UIApplication.shared.open(url)
    }
    
    // MARK: - SRSwipeUpViewDelegate
    
    func didChooseQuizMultipleImageAnswer(_ widget: QuizMultipleImageView, isYes: Bool) {
        
    }
    
    func didSwipeUp(_ widget: SRSwipeUpView) -> Bool {
        let request = SRStatistic(type: .click, value: widget.swipeUpWidget.url)
        analytics?.sendWidgetReaction(request, widget: widget)
        
        guard let url = URL(string: widget.swipeUpWidget.url) else { return false }
        guard UIApplication.shared.canOpenURL(url) else { return false }
        progress?.pauseAutoscrolling()
        UIApplication.shared.open(url)
        return true
    }
}
