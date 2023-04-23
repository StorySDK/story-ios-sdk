//
//  SRWidgetConstructor.swift
//  
//
//  Created by Aleksei Cherepanov on 20.05.2022.
//

import UIKit

final class SRWidgetConstructor {
    static func makeWidget(_ widget: SRWidget, story: SRStory, sdk: StorySDK) -> SRWidgetView {
        var content = widget.content
        var imageUrl: URL?
        if case .image(let url, let newContent) = content {
            content = newContent
            imageUrl = url
        }
        let loader = sdk.imageLoader
        let logger = sdk.logger
        switch content {
        case .rectangle(let rectangleWidget):
            return SRRectangleView(story: story, data: widget, rectangleWidget: rectangleWidget, imageUrl: imageUrl, loader: loader, logger: logger)
        case .ellipse(let ellipseWidget):
            return SREllipseView(story: story, data: widget, ellipseWidget: ellipseWidget, imageUrl: imageUrl, loader: loader, logger: logger)
        case .emoji(let emojiWidget):
            return EmojiReactionView(story: story, data: widget, emojiReactionWidget: emojiWidget)
        case .chooseAnswer(let answerWidget):
            return ChooseAnswerView(story: story, data: widget, chooseAnswerWidget: answerWidget)
        case .text(let textWidget):
            return SRTextView(story: story, data: widget, textWidget: textWidget, imageUrl: imageUrl, loader: loader, logger: logger)
        case .swipeUp(let swipeUpWidget):
            return SRSwipeUpView(story: story, data: widget, swipeUpWidget: swipeUpWidget, imageUrl: imageUrl, loader: loader, logger: logger)
        case .clickMe(let clickMeWidget):
            return SRClickMeView(story: story, data: widget, clickMeWidget: clickMeWidget, imageUrl: imageUrl, loader: loader, logger: logger)
        case .slider(let sliderWidget):
            return SliderView( story: story, data: widget, sliderWidget: sliderWidget)
        case .question(let questionWidget):
            return QuestionView(story: story, data: widget, questionWidget: questionWidget)
        case .talkAbout(let talkAboutWidget):
            return SRTalkAboutView(story: story, data: widget, talkAboutWidget: talkAboutWidget, loader: loader)
        case .giphy(let giphyWidget):
            return SRGiphyView(data: widget, giphyWidget: giphyWidget, loader: loader)
        case .image:
            fatalError("Unexpected widget type")
        }
    }
    
    static func calcWidgetPosition(_ widget: SRWidget, story: SRStory) -> CGRect {
        let defaultStorySize = CGSize.defaultStory
        let position = widget.position
        let x = position.x
        let y = position.y
        let width = position.realWidth
        let height = position.realHeight
        return CGRect(
            x: x / defaultStorySize.width,
            y: y / defaultStorySize.height,
            width: width / defaultStorySize.width,
            height: height / defaultStorySize.width
        )
    }
}

extension CGSize {
    static let defaultStory = CGSize(width: 1080, height: 1920)
    static let largeStory = CGSize(width: 1080, height: 2338)
}
