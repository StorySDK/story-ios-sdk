//
//  SRInteractiveWidgetView.swift
//  
//
//  Created by Aleksei Cherepanov on 25.05.2022.
//

import UIKit

protocol SRWidgetLoadDelegate: AnyObject {
    func didWidgetLoad(_ widget: SRInteractiveWidgetView)
}

public class SRInteractiveWidgetView: SRWidgetView {
    let story: SRStory
    weak var delegate: SRInteractiveWidgetDelegate?
    
    init(story: SRStory, data: SRWidget) {
        self.story = story
        super.init(data: data)
    }
}

typealias SRInteractiveWidgetDelegate = SRTalkAboutViewDelegate & ChooseAnswerViewDelegate & EmojiReactionViewDelegate & QuestionViewDelegate & SliderViewDelegate & SRClickMeViewDelegate & SRSwipeUpViewDelegate & QuizMultipleImageViewDelegate & QuizOneAnswerViewDelegate & QuizMultipleAnswerViewDelegate & SRWidgetLoadDelegate
