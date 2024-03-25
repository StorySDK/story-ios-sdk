//
//  SRDefaultWidgetResponder.swift
//  
//
//  Created by Aleksei Cherepanov on 24.05.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

final class SRDefaultWidgetResponder: NSObject, SRWidgetResponder {
    var onStoriesClosed: (() -> Void)?
    
    let storySdk: StorySDK
    var containerFrame: SRRect = .zero
    var onMethodCall: ((String?) -> Void)?
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
#if os(iOS)
    func needShowKeyboard(_ widget: SRTalkAboutView) {
        widget.endEditing(true)
        let vc = SRTalkAboutViewController(
            story: widget.story,
            defaultStorySize: widget.defaultStorySize,
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
#elseif os(macOS)
    func needShowKeyboard(_ widget: SRTalkAboutView) {
        
    }
#endif
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
            analytics?.dataStorage?.totalScore += Int(score.points ?? 0)
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
            analytics?.dataStorage?.totalScore += Int(score.points ?? 0)
        }
    }
    
    func didChooseOneAnswer(_ widget: QuizOneAnswerView, answer: String, score: SRScore?) {
        let request = SRStatistic(type: .answer, value: answer)
        analytics?.sendWidgetReaction(request, widget: widget)
        
        progress?.pauseAutoscrollingUntil(.now() + pauseInterval)
        
        if let score = score {
            analytics?.dataStorage?.totalScore += Int(score.points ?? 0)
        }
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
    
    func didClickButton(_ widget: SRClickMeView) {
        let request = SRStatistic(type: .click, value: widget.clickMeWidget.url)
        analytics?.sendWidgetReaction(request, widget: widget)
        
        let clickMeWidget = widget.clickMeWidget
        guard let actionType = clickMeWidget.actionType else { return }
        
        switch actionType {
        case .story:
            // TODO: add scroll to partical story by id
            
            onMethodCall?("scrollNext")
            progress?.scrollNext()
        case .link:
            guard let url = URL(string: clickMeWidget.url) else {
                onMethodCall?("scrollNext")
                progress?.scrollNext()
                return
            }
            guard StoryWorkspace.shared.canOpen(url) else {
                onMethodCall?(clickMeWidget.url)
                return
            }
            
            progress?.pauseAutoscrolling()
            StoryWorkspace.shared.open(url)
        case .custom:
            guard let customAction = clickMeWidget.customFields?.ios else {
                return
            }
            
            guard let url = URL(string: customAction) else {
                return
            }
            
            guard StoryWorkspace.shared.canOpen(url) else {
                onMethodCall?(customAction)
                progress?.scrollNext()
                return
            }
        }
    }
    
    // MARK: - SRSwipeUpViewDelegate
    
    func didChooseQuizMultipleImageAnswer(_ widget: QuizMultipleImageView, answer: String) {
        let request = SRStatistic(type: .answer, value: answer)
        analytics?.sendWidgetReaction(request, widget: widget)
        
        progress?.pauseAutoscrollingUntil(.now() + pauseInterval)
    }
    
    func didSwipeUp(_ widget: SRSwipeUpView) -> Bool {
        let request = SRStatistic(type: .click, value: widget.swipeUpWidget.url)
        analytics?.sendWidgetReaction(request, widget: widget)
        
        guard let url = URL(string: widget.swipeUpWidget.url) else { return false }
        guard StoryWorkspace.shared.canOpen(url) else { return false }
        progress?.pauseAutoscrolling()
        StoryWorkspace.shared.open(url)
        return true
    }
    
    func didWidgetLoad(_ widget: SRInteractiveWidgetView) {
        guard let canvas = widget.superview?.superview as? SRStoryCanvasView else { return }
        canvas.didWidgetLoad(widget)
    }
}
