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
    /// Story conguration
    var configuration: SRConfiguration { get }
    /// Progress controller which take care about progress bar state
    var progressController: SRProgressController? { get set }
    /// Taking care about  widget actions
    var widgetResponder: SRWidgetResponder? { get set }
    /// Number of stories in the group
    var numberOfItems: Int { get }
    /// Stories collection has been updated
    var onReloadData: (() -> Void)? { get set }
    /// An error has been received
    var onErrorReceived: ((Error) -> Void)? { get set }
    /// Load stories for the group
    func loadStories(group: StoryGroup)
    /// Configures cell with a story with index
    func setupCell(_ cell: SRStoryCell, index: Int)
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
    /// When user scrolled
    func didScroll(offset: Float, contentWidth: Float)
    /// When user tapped on a widget and we need to pause autoscrolling for a while
    func didInteract()
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
}

public typealias SRRect = CGRect

protocol SRWidgetResponderStorage: AnyObject {
    /// Current Story group
    var group: StoryGroup? { get set }
    /// View controller frame in absulute coordinates
    var containerFrame: SRRect { get set }
    /// Needs to lift up the view when the keyboard has appeared
    var onUpdateTransformNeeded: ((Float) -> Void)? { get set }
    /// Progress controller which take care about progress bar state
    var progressController: SRProgressController? { get set }
}

typealias SRWidgetResponder = SRWidgetResponderStorage & TalkAboutViewDelegate & ChooseAnswerViewDelegate & EmojiReactionViewDelegate & QuestionViewDelegate & SliderViewDelegate & SRClickMeViewDelegate & SRSwipeUpViewDelegate
