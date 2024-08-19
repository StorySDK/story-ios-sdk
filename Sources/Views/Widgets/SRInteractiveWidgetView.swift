//
//  SRInteractiveWidgetView.swift
//  StorySDK
//
//  Created by Aleksei Cherepanov on 25.05.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

protocol SRWidgetLoadDelegate: AnyObject {
    func didWidgetLoad(_ widget: SRInteractiveWidgetView)
}

public class SRInteractiveWidgetView: SRWidgetView {
    let story: SRStory
    weak var delegate: SRInteractiveWidgetDelegate?
    
    init(story: SRStory, defaultStorySize: CGSize, data: SRWidget) {
        self.story = story
        super.init(data: data, defaultStorySize: defaultStorySize)
        
        backgroundColor = .clear
    }
}

typealias SRInteractiveWidgetDelegate = SRTalkAboutViewDelegate & ChooseAnswerViewDelegate & EmojiReactionViewDelegate & QuestionViewDelegate & SliderViewDelegate & SRClickMeViewDelegate & SRLinkViewDelegate & SRSwipeUpViewDelegate & QuizMultipleImageViewDelegate & QuizOneAnswerViewDelegate & QuizMultipleAnswerViewDelegate & SRWidgetLoadDelegate
