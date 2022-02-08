//
//  WidgetContent.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

import UIKit

public struct WidgetContent {
    public let type: WidgetTypes
    public let params: WidgetType
    public let widgetImage: String?
    
    public init() {
        self.type = WidgetTypes.RECTANGLE
        self.params = WidgetType.rectangle(RectangleWidget())
        self.widgetImage = nil
    }
    
    public init(from dict: Json) {
        self.type = WidgetTypes(rawValue: dict["type"] as! String) ?? .RECTANGLE
        self.widgetImage = dict["widgetImage"] as? String ?? nil
        let widgetDict = dict["params"] as! Json
        switch type {
        case .RECTANGLE:
            self.params = WidgetType.rectangle(RectangleWidget(from: widgetDict))
        case .ELLIPSE:
            self.params = WidgetType.ellipse(EllipseWidget(from: widgetDict))
        case .TEXT:
            self.params = WidgetType.text(TextWidget(from: widgetDict))
        case .SWIPE_UP:
            self.params = WidgetType.swipe_up(SwipeUpWidget(from: widgetDict))
        case .SLIDER:
            self.params = WidgetType.slider(SliderWidget(from: widgetDict))
        case .QUESTION:
            self.params = WidgetType.question(QuestionWidget(from: widgetDict))
        case .CLICK_ME:
            self.params = WidgetType.click_me(ClickMeWidget(from: widgetDict))
        case .TALK_ABOUT:
            self.params = WidgetType.talk_about(TalkAboutWidget(from: widgetDict))
        case .EMOJI_REACTION:
            self.params = WidgetType.emoji(EmojiReactionWidget(from: widgetDict))
        case .TIMER:
            self.params = WidgetType.timer(TimerWidget(from: widgetDict))
        case .CHOOSE_ANSWER:
            self.params = WidgetType.choose_answer(ChooseAnswerWidget(from: widgetDict))
        case .GIPHY:
            self.params = WidgetType.giphy(GiphyWidget(from: widgetDict))
        }
    }
}
