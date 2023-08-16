//
//  SRWidgetConstructor.swift
//  
//
//  Created by Aleksei Cherepanov on 20.05.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

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
//            switch rectangleWidget.fillColor {
//            case .image(let url, let isFilled) {
//                //content = newContent
//                imageUrl = url
//            }
//            default:
//                break
//            }
            if case .image(let url, let _) = rectangleWidget.fillColor {
                imageUrl = url
            }
            
            if case .video(let url, let _) = rectangleWidget.fillColor {
                imageUrl = url
            }
            
            return SRRectangleView(story: story, data: widget, rectangleWidget: rectangleWidget, imageUrl: imageUrl, loader: loader, logger: logger)
        case .imageWidget(let imgWidget):
            imageUrl = imgWidget.imageUrl
            
            return SRImageWidgetView(story: story, data: widget, url: imageUrl, loader: loader, logger: logger)
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
        case .quizOneAnswer(let oneAnswerWidget):
            return QuizOneAnswerView(story: story, data: widget, widget: oneAnswerWidget)
        case .quizMultipleImageAnswer(let questionWidget):
            return QuizMultipleImageView(story: story, data: widget, quizWidget: questionWidget, loader: loader, logger: logger)
        case .quizMultipleAnswers(let multipleAnswerWidget):
            return QuizMultipleAnswerView(story: story, data: widget, widget: multipleAnswerWidget)
        case .quizOpenAnswer(let openAnswerWidget):
            return QuizOpenAnswerView(story: story, data: widget, widget: openAnswerWidget, loader: loader)
        case .quizRate(let rateWidget):
            return QuizRateView(story: story, data: widget, widget: rateWidget)
        case .image:
            fatalError("Unexpected widget type")
        case .unknownWidget(let unknownWidget):
            return UnknownWidgetView(story: story, data: widget ,widget: unknownWidget)
        }
    }
    
    static func calcWidgetPosition(_ widget: SRWidget, story: SRStory) -> CGRect {
        let defaultStorySize = CGSize.largeStory
        
        let screenWidth = StoryScreen.screenBounds.width * StoryScreen.screenNativeScale
        let screenHeight = defaultStorySize.height
        
        var xOffset = (screenWidth - defaultStorySize.width) / 2
        
        xOffset = max(xOffset, 0.0)
        
        let position = widget.position//.origin
        var x = position.x + xOffset
        let y = position.y
        let width: CGFloat = widget.position.origin.width
        let height: CGFloat
        
        switch widget.content {
        case .imageWidget(_):
            height = widget.position.origin.height / 3
        default:
            height = widget.position.origin.height
        }
        
        let scaleW = screenWidth / defaultStorySize.width
        let scaleH = screenHeight / defaultStorySize.height
        
        var originalRemainder = defaultStorySize.width - (position.x + width)
        if fabs(position.x - originalRemainder) < 5 {
            let center = true
            
            x = (screenWidth - width * scaleW) / 2
        }
        
        return CGRect(
            x: x / /*defaultStorySize.width,*/screenWidth,
            y: y / /*defaultStorySize.height*/screenHeight,
            width: (width * scaleW) / screenWidth /*defaultStorySize.width*/ /*screenWidth*/,
            height: (height * scaleH) / screenHeight/*defaultStorySize.width*/ /*defaultStorySize.height*/
        )
    }
}

extension CGSize {
    static let defaultStory = CGSize(width: 1080, height: 1920)
    static let largeStory = CGSize(width: 1080, height: 2338)
}
