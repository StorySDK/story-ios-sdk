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
    var group: StoryGroup?
    var onUpdateTransformNeeded: ((Float) -> Void)?
    weak var progressController: SRProgressController?
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
    
    private func sendReaction(_ reaction: SRStatistic, widget: SRInteractiveWidgetView) {
        let widgetId = widget.data.id
        var reaction = reaction
        reaction.storyId = widget.story.id
        reaction.widgetId = widgetId
        reaction.groupId = group?.id
        
        storySdk.sendStatistic(reaction) { [weak storySdk] result in
            switch result {
            case .success:
                storySdk?.userDefaults.setReaction(widgetId: widgetId, value: reaction.value)
            case .failure(let error):
                print("StorySDK.StoriesVC > Error:", error.localizedDescription)
            }
        }
    }
    
    // MARK: - TalkAboutViewDelegate
    
    func needShowKeyboard(_ widget: TalkAboutView) {
        guard widget.isTextFieldActive else { return }
        var bottom = containerFrame.maxY
        bottom -= widget.convert(widget.bounds, to: nil).maxY
        bottom -= 50 // Space between widget and keyboard
        let delta = keyboardHeight - Float(bottom)
        progressController?.pauseAutoscrolling()
        guard delta > 0 else { return }
        onUpdateTransformNeeded?(-delta)
    }
    
    func needHideKeyboard(_ widget: TalkAboutView) {
        onUpdateTransformNeeded?(0)
        progressController?.startAutoscrollingAfter(.now() + .seconds(3))
    }
    
    func didSentTextAbout(_ widget: TalkAboutView, text: String?) {
        let request = SRStatistic(type: .answer, value: text)
        sendReaction(request, widget: widget)
    }
    
    // MARK: - ChooseAnswerViewDelegate
    
    func didChooseAnswer(_ widget: ChooseAnswerView, answer: String) {
        let request = SRStatistic(type: .answer, value: answer)
        sendReaction(request, widget: widget)
        progressController?.pauseAutoscrollingUntil(.now() + .seconds(3))
        
        guard answer == widget.chooseAnswerWidget.correct else { return }
        guard let canvas = widget.superview?.superview as? SRStoryCanvasView else { return }
        canvas.startConfetti()
    }
    
    // MARK: - EmojiReactionViewDelegate
    
    func didChooseEmojiReaction(_ widget: EmojiReactionView, emoji: String) {
        let request = SRStatistic(type: .answer, value: emoji )
        sendReaction(request, widget: widget)
        progressController?.pauseAutoscrollingUntil(.now() + .seconds(3))
    }
    
    // MARK: - QuestionViewDelegate
    
    func didChooseQuestionAnswer(_ widget: QuestionView, isYes: Bool) {
        let request = SRStatistic(type: .answer, value: isYes ? "confirm" : "decline")
        sendReaction(request, widget: widget)
        progressController?.pauseAutoscrollingUntil(.now() + .seconds(3))
    }
    
    // MARK: - SliderViewDelegate
    
    func didChooseSliderValue(_ widget: SliderView, value: Float) {
        let request = SRStatistic(type: .answer, value: "\(Int(value * 100))%")
        sendReaction(request, widget: widget)
        progressController?.pauseAutoscrollingUntil(.now() + .seconds(3))
    }
    
    // MARK: - SRClickMeViewDelegate
    
    func didClickedButton(_ widget: SRClickMeView) {
        let request = SRStatistic(type: .click, value: widget.clickMeWidget.url)
        sendReaction(request, widget: widget)
        
        guard let url = URL(string: widget.clickMeWidget.url) else { return }
        guard UIApplication.shared.canOpenURL(url) else { return }
        progressController?.pauseAutoscrolling()
        UIApplication.shared.open(url)
    }
    
    // MARK: - SRSwipeUpViewDelegate
    
    func didSwipeUp(_ widget: SRSwipeUpView) {
        let request = SRStatistic(type: .click, value: widget.swipeUpWidget.url)
        sendReaction(request, widget: widget)
        
        guard let url = URL(string: widget.swipeUpWidget.url) else { return }
        guard UIApplication.shared.canOpenURL(url) else { return }
        progressController?.pauseAutoscrolling()
        UIApplication.shared.open(url)
    }
}
