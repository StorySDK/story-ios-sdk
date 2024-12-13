//
//  SRStoriesDataStorage.swift
//  
//
//  Created by Aleksei Cherepanov on 19.05.2022.
//

import Foundation
import Combine
#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

protocol SRStoriesDataStorage: AnyObject {
    /// Current Story group
    var group: SRStoryGroup? { get }
    /// Story conguration
    var configuration: SRConfiguration { get }
    /// Progress controller which take care about progress bar state
    var progress: SRProgressController? { get set }
    /// To report about analytics events
    var analytics: SRAnalyticsController? { get set }
    /// Taking care about  widget actions
    var widgetResponder: SRWidgetResponder? { get set }
    /// To process swipe up gesture
    var gestureRecognizer: SRStoriesGestureRecognizer? { get set }
    /// Number of stories in the group
    var numberOfItems: Int { get }
    /// Stories collection has been updated
    var onReloadData: (() -> Void)? { get set }
    /// Calls when a group don't have any stories or error
    var onGotEmptyGroup: (() -> Void)? { get set }
    /// An error has been received
    var onErrorReceived: ((Error) -> Void)? { get set }
    /// Updates header view
    var onUpdateHeader: ((HeaderInfo) -> Void)? { get set }
    /// Load stories for the group
    func loadStories(group: SRStoryGroup, asOnboading: Bool)
    /// Configures cell with a story with index
    func setupCell(_ cell: SRStoryCell, index: Int)
    /// Prepare cell for displaying
    func willDisplay(_ cell: SRStoryCell, index: Int)
    /// Clean cell displaying connected staff
    func endDisplaying(_ cell: SRStoryCell, index: Int)
    /// Returns id of the story at index
    func storyId(atIndex index: Int) -> String?
    func storyShortDataId(atIndex index: Int) -> String?
    /// Default story size (small, large)
    func storySize() -> CGSize
    
    var onFilled: ((Bool) -> Void)? { get set }
    
    var totalScore: Int { get set }
}

protocol SRStoryCell: AnyObject {
    var backgroundColors: [StoryColor]? { get set }
    var backgroundImage: StoryImage? { get set }
    var backgroundVideo: URL? { get set }
    var cancellables: Set<AnyCancellable> { get set }
    var needShowTitle: Bool { get set }
    var defaultStorySize: CGSize? { get set }
    var isLoading: Bool { get set }
    
    func appendWidget(_ widget: SRWidgetView, position: CGRect)
    
    func widgets() -> [SRWidgetView]?
    
    func presentParticles()
}

protocol SRProgressComponent: AnyObject {
    var numberOfItems: Int { get set }
    var progress: Float { get set }
    var activeColor: StoryColor { get set }
    var animationDuration: TimeInterval { get set }
    var totalDuration: TimeInterval { get set }
    var durations: [TimeInterval] { get set }
}

protocol SRProgressController: AnyObject {
    /// To report about analytics events
    var analytics: SRAnalyticsController? { get set }
    /// Reports loading states for stories with id
    var isLoading: [String: Bool] { get set }
    /// Number of components
    var numberOfItems: Int { get set }
    /// Duration
    var totalDuration: TimeInterval { get set }
    /// Duration of each story
    var durations: [TimeInterval] { get set }
    /// Progress bar tint color
    var activeColor: StoryColor? { get set }
    /// It’s used when the progress bar needs to be updated
    var onProgressUpdated: ((Float) -> Void)? { get set }
    /// When we need to scroll to the next story
    var onScrollToStory: ((Int, Bool) -> Void)? { get set }
    /// When timer finished
    var onScrollCompleted: (() -> Void)? { get set }
    /// When user is going to scroll
    func willBeginDragging()
    /// When user stopped scrolling
    func didEndDragging()
    /// View starter transition
    func willBeginTransition()
    /// View finished transition
    func didEndTransition()
    /// When user scrolled
    func didScroll(offset: Float, contentWidth: Float)
    /// Updates progress component
    func setupProgress(_ component: SRProgressComponent)
    /// Starts scrolling timer
    func startAutoscrolling()
    /// Starts scrolling timer after dalay
    func startAutoscrollingAfter(_ deadline: DispatchTime)
    /// Stops scrolling timer
    func pauseAutoscrolling()
    /// Stops scrolling timer and start after
    func pauseAutoscrollingUntil(_ deadline: DispatchTime)
    /// Scroll to the next story
    func scrollNext()
    /// Scroll to the previous story
    func scrollBack()
}

public typealias SRRect = CGRect

protocol SRWidgetResponderStorage: AnyObject {
    /// View controller frame in absulute coordinates
    var containerFrame: SRRect { get set }
    /// Need to present view controller
    var presentTalkAbout: ((SRTalkAboutViewController) -> Void)? { get set }
    /// Progress controller which take care about progress bar state
    var progress: SRProgressController? { get set }
    /// To report about analytics events
    var analytics: SRAnalyticsController? { get set }
    /// When external custom widget action should be call
    var onMethodCall: ((String?) -> Void)? { get set }
    // TODO: Desc
    var onStoriesClosed: (() -> Void)? { get set }
    
    var onStoriesLoading: (() -> Void)? { get set }
    
    var onStoriesLoaded: (() -> Void)? { get set }
}

protocol SRAnalyticsController: AnyObject {
    var dataStorage: SRStoriesDataStorage? { get set }
    /// Sends information about interaction with the widget
    func sendWidgetReaction(_ reaction: SRStatistic,
                            widget: SRInteractiveWidgetView)
    /// Currently displayed story did changed
    func storyDidChanged(to index: Int, byUser: Bool)
    /// When a user opens the group
    func reportGroupOpen()
    /// When a user closes the group
    func reportGroupClose()
    /// When group or story has been swiped forward
    func reportSwipeForward(from storyId: String?)
    /// When group or story has been swiped backward
    func reportSwipeBackward(from storyId: String?)
    
    func reportQuizStart(time: Date)
    
    func reportQuizFinish(time: Date)
    
    func getCurrentShortStoryId() -> String?
}

typealias SRWidgetResponder = SRWidgetResponderStorage & SRInteractiveWidgetDelegate

struct HeaderInfo {
    var title: String?
    var duration: String?
    var icon: StoryImage?
    var isHidden: Bool
    var isProhibitToClose: Bool = false
    var isProgressHidden: Bool = false
    var storiesCount: Int = 0
}
