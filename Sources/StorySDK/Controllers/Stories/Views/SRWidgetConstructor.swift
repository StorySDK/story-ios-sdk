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
        var limitY = !widget.positionLimits.isResizableY
        
        switch widget.content {
        case .clickMe(_):
            limitY = true
        default:
            break
        }
        
        let screenWidth = StoryScreen.screenBounds.width * StoryScreen.screenNativeScale
        let screenHeight = defaultStorySize.height * StoryScreen.screenNativeScale
        
        var xOffset = (screenWidth - defaultStorySize.width) / 2
        
        xOffset = 0.0 //max(xOffset, 0.0)
        
        //defaultStorySize == .largeStory
        
        let positionRes: SRPosition?
        if CGSize.isSmallStories() {
            positionRes = widget.positionByResolutions.res360x640
        } else {
            positionRes = widget.positionByResolutions.res360x780
        }
        
        guard let position = positionRes else {
            return CGRect.zero
        }
    
        var x: CGFloat = (position.x + xOffset) * StoryScreen.screenNativeScale
        let y: CGFloat = position.y * StoryScreen.screenNativeScale
        let width: CGFloat = position.realWidth //origin.width
        
        let height = widget.position.realHeight// origin.height
        
        let scaleW = screenWidth / defaultStorySize.width
        let scaleH = screenHeight / defaultStorySize.height
        
        var originalRemainder = defaultStorySize.width - (position.x + width)
        if fabs(position.x - originalRemainder) < 5 {
            let center = true
            
            x = (screenWidth - width * scaleW) / 2
        }
        
        var newHeight: CGFloat
        if limitY {
            //let t = 0
            newHeight = (height * scaleH) / (defaultStorySize.height * StoryScreen.screenNativeScale)
            
            //newHeight = (height * scaleH) / (defaultStorySize.height * StoryScreen.screenNativeScale)
        } else {
            newHeight = (height * scaleH) / screenHeight
        }
        
        return CGRect(
            x: x / /*defaultStorySize.width,*/screenWidth,
            y: y / /*defaultStorySize.height*/screenHeight,
            width: (width * scaleW) / screenWidth /*defaultStorySize.width*/ /*screenWidth*/,
            height: newHeight //(height * scaleH) / screenHeight/*defaultStorySize.width*/ /*defaultStorySize.height*/
        )
    }
}

extension CGSize {
    static let defaultStory = CGSize(width: 1080, height: 1920)
    
    static let largeStory = CGSize(width: 360, height: 780)
    static let smallStory = CGSize(width: 360, height: 640)
    
    static func defaultOnboardingSize() -> CGSize {
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        
        let largeRatio: CGFloat = largeStory.height / largeStory.width
        let smallRatio: CGFloat = smallStory.height / smallStory.width
        
        let deviceRatio: CGFloat = h / w
            
        if abs(largeRatio - deviceRatio) < 0.005 {
            return largeStory
            //return UIScreen.main.bounds.size
        } else if abs(smallRatio - deviceRatio) < 0.005 {
            return smallStory
        } else {
            return largeStory
        }
    }
    
    static func isSmallStories() -> Bool {
        let test = defaultOnboardingSize() == .smallStory
        
        return test
    }
}
