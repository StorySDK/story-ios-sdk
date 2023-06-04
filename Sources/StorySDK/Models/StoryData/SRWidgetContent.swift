//
//  SRWidgetContent.swift
//  
//
//  Created by Aleksei Cherepanov on 23.05.2022.
//

import Foundation

public indirect enum SRWidgetContent: Decodable {
    case rectangle(SRRectangleWidget)
    case ellipse(SREllipseWidget)
    case emoji(SREmojiReactionWidget)
    case chooseAnswer(SRChooseAnswerWidget)
    case text(SRTextWidget)
    case swipeUp(SRSwipeUpWidget)
    case clickMe(SRClickMeWidget)
    case slider(SRSliderWidget)
    case question(SRQuestionWidget)
    case talkAbout(SRTalkAboutWidget)
    case giphy(SRGiphyWidget)
    case image(URL, SRWidgetContent)
    
    case quizOneAnswer(SRQuizOneAnswerWidget)
    case quizMultipleAnswers(SRQuizOneAnswerWidget)
    case quizMultipleImageAnswer(SRQuizMultipleImageWidget)
    case quizOpenAnswer(SRQuizOpenAnswerWidget)
    case quizRate(SRQuizRateWidget)
    
    case unknownWidget(SRUnknownWidget)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let innerType = try container.decode(String.self, forKey: .type)
        
        let type = SRWidgetTypes(rawValue: innerType) ?? .unknown
        let content = try SRWidgetContent.decodeType(type, container: container)
        if let url = try? container.decode(URL.self, forKey: .widgetImage) {
            self = .image(url, content)
        } else {
            self = content
        }
    }
    
    private static func decodeType(_ type: SRWidgetTypes, container: KeyedDecodingContainer<CodingKeys>) throws -> SRWidgetContent {
        switch type {
        case .rectangle:
            let params = try container.decode(SRRectangleWidget.self, forKey: .params)
            return .rectangle(params)
        case .ellipse:
            let params = try container.decode(SREllipseWidget.self, forKey: .params)
            return .ellipse(params)
        case .text:
            let params = try container.decode(SRTextWidget.self, forKey: .params)
            return .text(params)
        case .swipeUp:
            let params = try container.decode(SRSwipeUpWidget.self, forKey: .params)
            return .swipeUp(params)
        case .slider:
            let params = try container.decode(SRSliderWidget.self, forKey: .params)
            return .slider(params)
        case .question:
            let params = try container.decode(SRQuestionWidget.self, forKey: .params)
            return .question(params)
        case .clickMe:
            let params = try container.decode(SRClickMeWidget.self, forKey: .params)
            return .clickMe(params)
        case .talkAbout:
            let params = try container.decode(SRTalkAboutWidget.self, forKey: .params)
            return .talkAbout(params)
        case .emojiReaction:
            let params = try container.decode(SREmojiReactionWidget.self, forKey: .params)
            return .emoji(params)
        case .chooseAnswer:
            let params = try container.decode(SRChooseAnswerWidget.self, forKey: .params)
            return .chooseAnswer(params)
        case .giphy:
            let params = try container.decode(SRGiphyWidget.self, forKey: .params)
            return .giphy(params)
        case .quizOneAnswer:
            let params = try container.decode(SRQuizOneAnswerWidget.self, forKey: .params)
            return .quizOneAnswer(params)
        case .quizMultipleAnswers:
            let params = try container.decode(SRQuizOneAnswerWidget.self, forKey: .params)
            return .quizMultipleAnswers(params)
        case .quizOneMultipleImage:
            let params = try container.decode(SRQuizMultipleImageWidget.self, forKey: .params)
            return .quizMultipleImageAnswer(params)
        case .quizOpenAnswer:
            let params = try container.decode(SRQuizOpenAnswerWidget.self, forKey: .params)
            return .quizOpenAnswer(params)
        case .quizRate:
            let params = try container.decode(SRQuizRateWidget.self, forKey: .params)
            return .quizRate(params)
        case .unknown:
            let widget = SRUnknownWidget(title: "Unknown widget type")
            return .unknownWidget(widget)
        }
    }
}

extension SRWidgetContent {
    enum CodingKeys: String, CodingKey {
        case type, params, widgetImage
    }
}

enum SRWidgetTypes: String, Decodable {
    case rectangle = "rectangle"
    case ellipse = "ellipse"
    case text = "text"
    case swipeUp = "swipe_up"
    case slider = "slider"
    case question = "question"
    case clickMe = "click_me"
    case talkAbout = "talk_about"
    case emojiReaction = "emoji_reaction"
    // case timer = "timer"
    case chooseAnswer = "choose_answer"
    case giphy = "giphy"
    case quizOneAnswer = "quiz_one_answer"
    case quizOneMultipleImage = "quiz_one_multiple_with_image"
    case quizOpenAnswer = "quiz_open_answer"
    case quizMultipleAnswers = "quiz_multiple_answers"
    case quizRate = "quiz_rate"
    case unknown = "unknown"
}
