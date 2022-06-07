//
//  SRInteractiveWidgetView.swift
//  
//
//  Created by Aleksei Cherepanov on 25.05.2022.
//

import UIKit

public class SRInteractiveWidgetView: SRWidgetView {
    let story: SRStory
    weak var delegate: SRIneractiveWidgetDelegate?
    
    init(story: SRStory, data: SRWidget) {
        self.story = story
        super.init(data: data)
    }
}

typealias SRIneractiveWidgetDelegate = TalkAboutViewDelegate & ChooseAnswerViewDelegate & EmojiReactionViewDelegate & QuestionViewDelegate & SliderViewDelegate & SRClickMeViewDelegate & SRSwipeUpViewDelegate