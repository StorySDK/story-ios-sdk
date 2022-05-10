//
//  WidgetType.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

import UIKit

public enum WidgetType {
    case rectangle(RectangleWidget),        // !
         ellipse(EllipseWidget),            // !
         emoji(EmojiReactionWidget),        // !
         choose_answer(ChooseAnswerWidget), // !
         text(TextWidget),                  // !
         swipe_up(SwipeUpWidget),           // !
         click_me(ClickMeWidget),           // !
         slider(SliderWidget),              // !
         question(QuestionWidget),          // !
         talk_about(TalkAboutWidget),       // !
         giphy(GiphyWidget),                // !
         timer(TimerWidget)                 // !
}
