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
        switch content {
        case .rectangle(let rectangleWidget):
            return RectangleView(
                data: widget,
                rectangleWidget: rectangleWidget
            )
        case .ellipse(let ellipseWidget):
            return EllipseView(
                data: widget,
                ellipseWidget: ellipseWidget
            )
        case .emoji(let emojiReactionWidget):
            return EmojiReactionView(
                story: story,
                data: widget,
                emojiReactionWidget: emojiReactionWidget
            )
        case .chooseAnswer(let chooseAnswerWidget):
            return ChooseAnswerView(
                story: story,
                data: widget,
                chooseAnswerWidget: chooseAnswerWidget
            )
        case .text(let textWidget):
            return SRTextView(
                story: story,
                data: widget,
                textWidget: textWidget,
                imageUrl: imageUrl,
                loader: sdk.imageLoader
            )
        case .swipeUp(let swipeUpWidget):
            return SRSwipeUpView(
                story: story,
                data: widget,
                swipeUpWidget: swipeUpWidget,
                imageUrl: imageUrl,
                loader: sdk.imageLoader
            )
        case .clickMe(let clickMeWidget):
            return SRClickMeView(
                story: story,
                data: widget,
                clickMeWidget: clickMeWidget,
                imageUrl: imageUrl,
                loader: sdk.imageLoader
            )
        case .slider(let sliderWidget):
            return SliderView(
                story: story,
                data: widget,
                sliderWidget: sliderWidget
            )
        case .question(let questionWidget):
            return QuestionView(
                story: story,
                data: widget,
                questionWidget: questionWidget
            )
        case .talkAbout(let talkAboutWidget):
            return TalkAboutView(
                story: story,
                data: widget,
                talkAboutWidget: talkAboutWidget,
                loader: sdk.imageLoader
            )
        case .giphy(let giphyWidget):
            return GiphyView(
                data: widget,
                giphyWidget: giphyWidget,
                loader: sdk.imageLoader
            )
        case .image:
            fatalError("Unexpected widget type")
        }
    }
    
    static func calcWidgetPosition(_ widget: SRWidget, story: SRStory) -> CGRect {
        let defaultStorySize = CGSize(width: 390, height: 694)
        let position = widget.position
        let x = position.x
        let y = position.y
        let height = position.realHeight
        let width = position.realWidth
        return CGRect(
            x: x / defaultStorySize.width,
            y: y / defaultStorySize.height,
            width: width / defaultStorySize.height,
            height: height / defaultStorySize.height
        )
    }
}
