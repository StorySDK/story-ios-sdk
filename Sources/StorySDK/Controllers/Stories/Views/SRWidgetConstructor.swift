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
    static var lastPositionAbsoluteY: CGFloat = 0.0
    static var lastPositionDY: CGFloat = 0.0
    
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
        case .videoWidget(let imgWidget):
            imageUrl = imgWidget.videoUrl
            
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
        let defaultStorySize = CGSize.defaultOnboardingSize()
        
        var limitX = !widget.positionLimits.isResizableX
        var limitY = !widget.positionLimits.isResizableY
        
        var stretchByWidth = false
        
        switch widget.content {
        case .clickMe(_):
            limitX = true
            limitY = true
        case .text(_):
            limitY = true
        case .videoWidget(_):
            stretchByWidth = true
        default:
            break
        }
        
        let screenWidth = StoryScreen.screenBounds.width * StoryScreen.screenNativeScale
        let screenHeight = StoryScreen.screenBounds.height * StoryScreen.screenNativeScale
        
        let positionRes: SRPosition?
        if CGSize.isSmallStories() {
            positionRes = widget.positionByResolutions.res360x640
        } else {
            positionRes = widget.positionByResolutions.res360x780
        }
        
        guard let position = positionRes else {
            return CGRect.zero
        }
        
        var dx = (position.x / defaultStorySize.width)
        var dy = (position.y / defaultStorySize.height)
        
        if (dy < lastPositionDY) {
            let betweenItems = position.y - lastPositionAbsoluteY
            let dh = betweenItems / defaultStorySize.height
            
            dy = lastPositionDY + dh
        }
        
        var width: CGFloat = position.realWidth
        let height = widget.position.realHeight
        
        let xCoeff = min(StoryScreen.screenBounds.width / defaultStorySize.width, 2.0)
        
        if stretchByWidth {
            width = ((width * xCoeff) / StoryScreen.screenBounds.width) * width
        }

        var newHeight: CGFloat = height
        var newWidth: CGFloat = min(width, defaultStorySize.width)
        
        if limitY {
            let old = newHeight
            newHeight = max(old, newHeight / (StoryScreen.screenBounds.height / defaultStorySize.height))
        }
        
        if stretchByWidth {
            newHeight = ((height * xCoeff) / StoryScreen.screenBounds.height) * defaultStorySize.height
            dx = (1 - (newWidth / defaultStorySize.width)) / 2
        }
        
        lastPositionAbsoluteY = position.y + position.realHeight
        
        let offsetBetween: CGFloat
        if stretchByWidth {
            offsetBetween = newHeight / defaultStorySize.height
        } else {
            offsetBetween = position.realHeight / StoryScreen.screenBounds.height
        }
        
        lastPositionDY = dy + offsetBetween
        
        return CGRect(
            x: dx,
            y: dy,
            width: newWidth / defaultStorySize.width,
            height: newHeight / defaultStorySize.height
        )
    }
}

extension CGSize {
    static let defaultStory = CGSize(width: 1080, height: 1920)
    
    static let largeStory = CGSize(width: 360, height: 780)
    static let smallStory = CGSize(width: 360, height: 640)
    
    static func defaultOnboardingSize() -> CGSize {
        smallStory
    }
    
    static func isSmallStories() -> Bool {
        defaultOnboardingSize() == .smallStory
    }
}
