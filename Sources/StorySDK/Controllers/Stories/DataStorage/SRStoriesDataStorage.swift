//
//  SRStoriesDataStorage.swift
//  
//
//  Created by Aleksei Cherepanov on 19.05.2022.
//

import Foundation
import Combine
import UIKit

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
    /// Need to dismiss screen
    var dismiss: (() -> Void)? { get set }
    /// An error has been received
    var onErrorReceived: ((Error) -> Void)? { get set }
    /// Updates header view
    var onUpdateHeader: ((HeaderInfo) -> Void)? { get set }
    /// Load stories for the group
    func loadStories(group: SRStoryGroup)
    /// Configures cell with a story with index
    func setupCell(_ cell: SRStoryCell, index: Int)
    /// Returns id of the story at index
    func storyId(atIndex index: Int) -> String?
}

protocol SRStoryCell: AnyObject {
    var backgroundColors: [UIColor]? { get set }
    var backgroundImage: UIImage? { get set }
    var cancellables: [Cancellable] { get set }
    var needShowTitle: Bool { get set }
    
    func appendWidget(_ widget: SRWidgetView, position: CGRect)
    func presentParticles()
}

protocol SRProgressComponent: AnyObject {
    var numberOfItems: Int { get set }
    var progress: Float { get set }
    var activeColor: UIColor { get set }
    var animationDuration: TimeInterval { get set }
}

protocol SRProgressController: AnyObject {
    /// To report about analytics events
    var analytics: SRAnalyticsController? { get set }
    /// Number of components
    var numberOfItems: Int { get set }
    /// Progress bar tint color
    var activeColor: UIColor? { get set }
    /// It’s used when the progress bar needs to be updated
    var onProgressUpdated: ((Float) -> Void)? { get set }
    /// When we need to scroll to the next story
    var onScrollToStory: ((Int) -> Void)? { get set }
    /// When timer finished
    var onScrollCompeted: (() -> Void)? { get set }
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
    /// Needs to lift up the view when the keyboard has appeared
    var onUpdateTransformNeeded: ((Float) -> Void)? { get set }
    /// Progress controller which take care about progress bar state
    var progress: SRProgressController? { get set }
    /// To report about analytics events
    var analytics: SRAnalyticsController? { get set }
}

protocol SRAnalyticsController: AnyObject {
    var dataStorage: SRStoriesDataStorage? { get set }
    /// Sends information about interaction with the widget
    func sendWidgetReaction(_ reaction: SRStatistic, widget: SRInteractiveWidgetView)
    /// Currently displayed story did changed
    func storyDidChanged(to index: Int, byUser: Bool)
    /// When a user opens the group
    func reportGroupOpen()
    /// When a user closes the group
    func reportGroupClose()
}

typealias SRWidgetResponder = SRWidgetResponderStorage & SRIneractiveWidgetDelegate

struct HeaderInfo {
    var title: String?
    var duration: String?
    var icon: UIImage?
    var isHidden: Bool
}
