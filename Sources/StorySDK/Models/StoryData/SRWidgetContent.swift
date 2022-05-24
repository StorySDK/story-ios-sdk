//
//  SRWidgetContent.swift
//  
//
//  Created by Aleksei Cherepanov on 23.05.2022.
//

import Foundation

public indirect enum SRWidgetContent: Decodable {
    case rectangle(RectangleWidget)
    case ellipse(EllipseWidget)
    case emoji(EmojiReactionWidget)
    case chooseAnswer(ChooseAnswerWidget)
    case text(TextWidget)
    case swipeUp(SwipeUpWidget)
    case clickMe(ClickMeWidget)
    case slider(SliderWidget)
    case question(QuestionWidget)
    case talkAbout(TalkAboutWidget)
    case giphy(GiphyWidget)
    case timer(TimerWidget)
    case image(URL, SRWidgetContent)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(WidgetTypes.self, forKey: .type)
        let content = try SRWidgetContent.decodeType(type, container: container)
        if let url = try? container.decode(URL.self, forKey: .widgetImage) {
            self = .image(url, content)
        } else {
            self = content
        }
    }
    
    private static func decodeType(_ type: WidgetTypes, container: KeyedDecodingContainer<CodingKeys>) throws -> SRWidgetContent {
        switch type {
        case .rectangle:
            let params = try container.decode(RectangleWidget.self, forKey: .params)
            return .rectangle(params)
        case .ellipse:
            let params = try container.decode(EllipseWidget.self, forKey: .params)
            return .ellipse(params)
        case .text:
            let params = try container.decode(TextWidget.self, forKey: .params)
            return .text(params)
        case .swipeUp:
            let params = try container.decode(SwipeUpWidget.self, forKey: .params)
            return .swipeUp(params)
        case .slider:
            let params = try container.decode(SliderWidget.self, forKey: .params)
            return .slider(params)
        case .question:
            let params = try container.decode(QuestionWidget.self, forKey: .params)
            return .question(params)
        case .clickMe:
            let params = try container.decode(ClickMeWidget.self, forKey: .params)
            return .clickMe(params)
        case .talkAbout:
            let params = try container.decode(TalkAboutWidget.self, forKey: .params)
            return .talkAbout(params)
        case .emojiReaction:
            let params = try container.decode(EmojiReactionWidget.self, forKey: .params)
            return .emoji(params)
        case .timer:
            let params = try container.decode(TimerWidget.self, forKey: .params)
            return .timer(params)
        case .chooseAnswer:
            let params = try container.decode(ChooseAnswerWidget.self, forKey: .params)
            return .chooseAnswer(params)
        case .giphy:
            let params = try container.decode(GiphyWidget.self, forKey: .params)
            return .giphy(params)
        }
    }
}

extension SRWidgetContent {
    enum CodingKeys: String, CodingKey {
        case type, params, widgetImage
    }
}

public enum WidgetTypes: String, Decodable {
    case rectangle = "rectangle"
    case ellipse = "ellipse"
    case text = "text"
    case swipeUp = "swipe_up"
    case slider = "slider"
    case question = "question"
    case clickMe = "click_me"
    case talkAbout = "talk_about"
    case emojiReaction = "emoji_reaction"
    case timer = "timer"
    case chooseAnswer = "choose_answer"
    case giphy = "giphy"
}
