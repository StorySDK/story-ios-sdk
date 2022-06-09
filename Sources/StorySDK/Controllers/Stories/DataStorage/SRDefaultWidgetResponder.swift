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
    var onUpdateTransformNeeded: ((Float) -> Void)?
    var pauseInterval: DispatchTimeInterval = .seconds(1)
    weak var progress: SRProgressController?
    weak var analytics: SRAnalyticsController?
    private var keyboardHeight: Float = 0
    
    init(sdk: StorySDK = .shared) {
        storySdk = sdk
        super.init()
        addNotifications()
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - Keyboard events
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        keyboardHeight = Float(keyboardRectangle.height)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        keyboardHeight = 0
    }
    
    // MARK: - TalkAboutViewDelegate
    
    func needShowKeyboard(_ widget: TalkAboutView) {
        guard widget.isTextFieldActive else { return }
        var bottom = containerFrame.maxY
        bottom -= widget.convert(widget.bounds, to: nil).maxY
        bottom -= 50 // Space between widget and keyboard
        let delta = keyboardHeight - Float(bottom)
        progress?.pauseAutoscrolling()
        guard delta > 0 else { return }
        onUpdateTransformNeeded?(-delta)
    }
    
    func needHideKeyboard(_ widget: TalkAboutView) {
        onUpdateTransformNeeded?(0)
        progress?.startAutoscrollingAfter(.now() + pauseInterval)
    }
    
    func didSentTextAbout(_ widget: TalkAboutView, text: String?) {
        let request = SRStatistic(type: .answer, value: text)
        analytics?.sendWidgetReaction(request, widget: widget)
    }
    
    // MARK: - ChooseAnswerViewDelegate
    
    func didChooseAnswer(_ widget: ChooseAnswerView, answer: String) {
        let request = SRStatistic(type: .answer, value: answer)
        analytics?.sendWidgetReaction(request, widget: widget)
        progress?.pauseAutoscrollingUntil(.now() + pauseInterval)
        
        guard answer == widget.chooseAnswerWidget.correct else { return }
        guard let canvas = widget.superview?.superview as? SRStoryCanvasView else { return }
        canvas.startConfetti()
    }
    
    // MARK: - EmojiReactionViewDelegate
    
    func didChooseEmojiReaction(_ widget: EmojiReactionView, emoji: String) {
        let request = SRStatistic(type: .answer, value: emoji )
        analytics?.sendWidgetReaction(request, widget: widget)
        progress?.pauseAutoscrollingUntil(.now() + pauseInterval)
    }
    
    // MARK: - QuestionViewDelegate
    
    func didChooseQuestionAnswer(_ widget: QuestionView, isYes: Bool) {
        let request = SRStatistic(type: .answer, value: isYes.questionWidgetString)
        analytics?.sendWidgetReaction(request, widget: widget)
        progress?.pauseAutoscrollingUntil(.now() + pauseInterval)
    }
    
    // MARK: - SliderViewDelegate
    
    func didChooseSliderValue(_ widget: SliderView, value: Float) {
        let request = SRStatistic(type: .answer, value: "\(Int(value * 100))%")
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
    
    func didSwipeUp(_ widget: SRSwipeUpView) {
        let request = SRStatistic(type: .click, value: widget.swipeUpWidget.url)
        analytics?.sendWidgetReaction(request, widget: widget)
        
        guard let url = URL(string: widget.swipeUpWidget.url) else { return }
        guard UIApplication.shared.canOpenURL(url) else { return }
        progress?.pauseAutoscrolling()
        UIApplication.shared.open(url)
    }
}
