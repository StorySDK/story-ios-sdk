//
//  SRWidgetConstructor.swift
//  
//
//  Created by Aleksei Cherepanov on 20.05.2022.
//

import UIKit

final class SRWidgetConstructor {
    static func makeWidget(_ widget: SRWidget, story: SRStory, sdk: StorySDK) -> SRWidgetView {
        let height: Double
        if case .double(let value) = widget.position.height {
            height = value
        } else {
            height = 0
        }
        
        let scale: CGFloat
        if let minHeight = widget.positionLimits.minHeight {
            scale = height / (minHeight * xScaleFactor)
        } else {
            scale = 1
        }
        
        var content = widget.content
        var imageUrl: URL?
        if case .image(let url, let newContent) = content {
            content = newContent
            imageUrl = url
        }
        switch content {
        case .rectangle(let rectangleWidget): // !!!
            return RectangleView(
                data: widget,
                rectangleWidget: rectangleWidget
            )
        case .ellipse(let ellipseWidget): // !!!
            return EllipseView(
                data: widget,
                ellipseWidget: ellipseWidget
            )
        case .emoji(let emojiReactionWidget):
            return EmojiReactionView(
                story: story,
                data: widget,
                emojiReactionWidget: emojiReactionWidget,
                scale: scale
            )
        case .chooseAnswer(let chooseAnswerWidget): // !!!
            return ChooseAnswerView(
                story: story,
                data: widget,
                chooseAnswerWidget: chooseAnswerWidget
            )
        case .text(let textWidget):
            return SRTextView(
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
        case .clickMe(let clickMeWidget): // !!!
            return SRClickMeView(
                story: story,
                data: widget,
                clickMeWidget: clickMeWidget,
                imageUrl: imageUrl,
                loader: sdk.imageLoader
            )
        case .slider(let sliderWidget): // !!?
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
                scale: scale
            )
        case .giphy(let giphyWidget): // !!!
            return GiphyView(
                data: widget,
                giphyWidget: giphyWidget,
                loader: sdk.imageLoader
            )
        case .timer(let timerWidget):
            return TimerView(
                story: story,
                data: widget,
                timerWidget: timerWidget
            )
        case .image:
            fatalError("Unexpected widget type")
        }
    }
    
    static func calcWidgetPosition(_ widget: SRWidget, story: SRStory) -> CGRect {
        let defaultStorySize = CGSize(width: 390, height: 694)
        let pos = widget.position
        var realHeight: Double = 0.0
        var realWidth: Double = 0.0
        let x = pos.x * xScaleFactor
        let y = pos.y * yScaleFactor
        if let width = pos.realWidth, width > 0 { realWidth = width }
        if let height = pos.realHeight, height > 0 { realHeight = height }
        realWidth *= xScaleFactor
        realHeight *= yScaleFactor
        return CGRect(
            x: x / defaultStorySize.width,
            y: y / defaultStorySize.height,
            width: realWidth / defaultStorySize.height,
            height: realHeight / defaultStorySize.height
        )
    }
}
