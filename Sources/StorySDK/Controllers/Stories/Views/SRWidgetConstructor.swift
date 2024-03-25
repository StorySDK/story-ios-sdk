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
    
    static var lastPositionResY: CGFloat = 0.0
    static var closestItemsByYPosition: CGFloat = 5.0
    
    static var currentStoryId: String?
    
    static func makeWidget(_ widget: SRWidget, story: SRStory,
                           defaultStorySize: CGSize, sdk: StorySDK) -> SRWidgetView {
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
            
            return SRRectangleView(story: story, defaultStorySize: defaultStorySize, data: widget, rectangleWidget: rectangleWidget, imageUrl: imageUrl, loader: loader, logger: logger)
        case .imageWidget(let imgWidget):
            imageUrl = imgWidget.imageUrl
            
            return SRImageWidgetView(story: story, defaultStorySize: defaultStorySize, data: widget, url: imageUrl, loader: loader, logger: logger)
        case .videoWidget(let imgWidget):
            imageUrl = imgWidget.videoUrl
            
            return SRImageWidgetView(story: story, defaultStorySize: defaultStorySize, data: widget, url: imageUrl, loader: loader, logger: logger)
        case .ellipse(let ellipseWidget):
            return SREllipseView(story: story, defaultStorySize: defaultStorySize, data: widget, ellipseWidget: ellipseWidget, imageUrl: imageUrl, loader: loader, logger: logger)
        case .emoji(let emojiWidget):
            return EmojiReactionView(story: story, defaultStorySize: defaultStorySize, data: widget, emojiReactionWidget: emojiWidget)
        case .chooseAnswer(let answerWidget):
            return ChooseAnswerView(story: story, defaultStorySize: defaultStorySize, data: widget, chooseAnswerWidget: answerWidget)
        case .text(let textWidget):
            return SRTextView(story: story, defaultStorySize: defaultStorySize, data: widget, textWidget: textWidget, imageUrl: imageUrl, loader: loader, logger: logger)
        case .swipeUp(let swipeUpWidget):
            return SRSwipeUpView(story: story, defaultStorySize: defaultStorySize, data: widget, swipeUpWidget: swipeUpWidget, imageUrl: imageUrl, loader: loader, logger: logger)
        case .clickMe(let clickMeWidget):
            return SRClickMeView(story: story, defaultStorySize: defaultStorySize, data: widget, clickMeWidget: clickMeWidget, imageUrl: imageUrl, loader: loader, logger: logger)
        case .slider(let sliderWidget):
            return SliderView( story: story, defaultStorySize: defaultStorySize, data: widget, sliderWidget: sliderWidget)
        case .question(let questionWidget):
            return QuestionView(story: story, defaultStorySize: defaultStorySize, data: widget, questionWidget: questionWidget)
        case .talkAbout(let talkAboutWidget):
            return SRTalkAboutView(story: story, defaultStorySize: defaultStorySize, data: widget, talkAboutWidget: talkAboutWidget, loader: loader)
        case .giphy(let giphyWidget):
            return SRGiphyView(data: widget, defaultStorySize: defaultStorySize,
                               giphyWidget: giphyWidget, loader: loader)
        case .quizOneAnswer(let oneAnswerWidget):
            return QuizOneAnswerView(story: story, defaultStorySize: defaultStorySize, data: widget, widget: oneAnswerWidget)
        case .quizMultipleImageAnswer(let questionWidget):
            return QuizMultipleImageView(story: story, defaultStorySize: defaultStorySize, data: widget, quizWidget: questionWidget, loader: loader, logger: logger)
        case .quizMultipleAnswers(let multipleAnswerWidget):
            return QuizMultipleAnswerView(story: story, defaultStorySize: defaultStorySize, data: widget, widget: multipleAnswerWidget)
        case .quizOpenAnswer(let openAnswerWidget):
            return QuizOpenAnswerView(story: story, defaultStorySize: defaultStorySize, data: widget, widget: openAnswerWidget, loader: loader)
        case .quizRate(let rateWidget):
            return QuizRateView(story: story, defaultStorySize: defaultStorySize, data: widget, widget: rateWidget)
        case .image:
            fatalError("Unexpected widget type")
        case .unknownWidget(let unknownWidget):
            return UnknownWidgetView(story: story, defaultStorySize: defaultStorySize, data: widget ,widget: unknownWidget)
        }
    }
    
    static func calcWidgetPosition(_ widget: SRWidget, story: SRStory,
                                   defaultStorySize: CGSize) -> CGRect {
        if currentStoryId != story.id {
            lastPositionAbsoluteY = 0.0
            lastPositionDY = 0.0
            lastPositionResY = 0.0
            
            currentStoryId = story.id
        }
        
        var limitX = !widget.positionLimits.isResizableX
        var limitY = !widget.positionLimits.isResizableY
        
        var stretchByWidth = false
        
        switch widget.content {
        case .clickMe(let btn):
            limitX = true
            limitY = true
        case .text(let t):
            limitY = true
        case .videoWidget(_):
            stretchByWidth = true
        default:
            break
        }
        
        let screenWidth = StoryScreen.screenBounds.width * StoryScreen.screenNativeScale
        let screenHeight = StoryScreen.screenBounds.height * StoryScreen.screenNativeScale
        
        let position: SRPosition = widget.getWidgetPosition(storySize: defaultStorySize)
        
        var dx = (position.x / defaultStorySize.width)
        var dy = (position.y / defaultStorySize.height)
        
        if abs(lastPositionResY - position.y) > closestItemsByYPosition {
            if (dy < lastPositionDY) {
                let betweenItems = position.y - lastPositionAbsoluteY
                if betweenItems > 0 {
                    let dh = betweenItems / defaultStorySize.height
                    
                    dy = lastPositionDY + dh
                }
            }
        }
        
        lastPositionResY = position.y
        
        var width: CGFloat = position.realWidth
        let height = widget.getWidgetPosition(storySize: defaultStorySize).realHeight
        
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
    
    static func isSmallStories(storySize: CGSize) -> Bool {
        storySize == .smallStory
    }
}
