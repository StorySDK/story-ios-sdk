//
//  SRDefaultAnalyticsController.swift
//  
//
//  Created by Aleksei Cherepanov on 07.06.2022.
//

import Foundation

class SRDefaultAnalyticsController: SRAnalyticsController {
    struct StoryInfo {
        var index: Int
        var id: String
        var openTime: Date = .init()
    }
    let storySdk: StorySDK
    var group: StoryGroup? { dataStorage?.group }
    weak var dataStorage: SRStoriesDataStorage?
    private var currentStory: StoryInfo?
    
    init(sdk: StorySDK = .shared) {
        storySdk = sdk
    }
    
    private func sendReaction(_ reaction: SRStatistic, completion: ((Result<Bool, Error>) -> Void)? = nil) {
        var reaction = reaction
        reaction.groupId = group?.id
        storySdk.sendStatistic(reaction) {  result in
            if case .failure(let error) = result {
                print("StorySDK.StoriesVC > Error:", error.localizedDescription)
            }
            completion?(result)
        }
    }
    
    func sendWidgetReaction(_ reaction: SRStatistic, widget: SRInteractiveWidgetView) {
        let widgetId = widget.data.id
        var reaction = reaction
        reaction.storyId = widget.story.id
        reaction.widgetId = widgetId
        
        sendReaction(reaction) { [weak storySdk] result in
            guard case .success = result else { return }
            storySdk?.userDefaults.setReaction(widgetId: widgetId, value: reaction.value)
        }
    }
    
    func reportGroupOpen() {
        sendReaction(.init(type: .open))
        guard let first = dataStorage?.storyId(atIndex: 0) else { return }
        currentStory = .init(index: 0, id: first)
    }
    
    func reportGroupClose() {
        sendReaction(.init(type: .close))
        postProcessStory()
    }
    
    func storyDidChanged(to index: Int, byUser: Bool) {
        guard let id = dataStorage?.storyId(atIndex: index) else { return }
        guard let old = currentStory else {
            currentStory = .init(index: index, id: id)
            return
        }
        guard old.index != index else { return }
        postProcessStory()
        currentStory = .init(index: index, id: id)
        guard byUser else { return }
        if old.index > index {
            reportSwipeBackward(id)
        } else {
            reportSwipeForward(id)
        }
    }
    
    func postProcessStory() {
        guard let story = currentStory else { return }
        let duration = -story.openTime.timeIntervalSinceNow
        if duration > 2 { reportImpression(story.id) }
        reportViewDuration(story.id, duration: duration)
    }
    
    func reportSwipeForward(_ storyId: String) {
        sendReaction(.init(type: .next, storyId: storyId))
    }
    
    func reportSwipeBackward(_ storyId: String) {
        sendReaction(.init(type: .back, storyId: storyId))
    }
    
    func reportImpression(_ storyId: String) {
        sendReaction(.init(type: .impression, storyId: storyId))
    }
    
    func reportViewDuration(_ storyId: String, duration: TimeInterval) {
        sendReaction(.init(type: .duration, storyId: storyId, value: "\(duration)"))
    }
}

final class SRDebugAnalyticsProxyController: SRDefaultAnalyticsController {
    override func sendWidgetReaction(_ reaction: SRStatistic, widget: SRInteractiveWidgetView) {
        debug("widgetReaction", "\(reaction)", widget.data.id)
        super.sendWidgetReaction(reaction, widget: widget)
    }
    
    override func reportGroupOpen() {
        debug("groupOpen")
        super.reportGroupOpen()
    }
    
    override func reportGroupClose() {
        debug("groupClose")
        super.reportGroupClose()
    }
    
    override func reportSwipeForward(_ storyId: String) {
        debug("swipeForward", storyId)
        super.reportSwipeForward(storyId)
    }
    
    override func reportSwipeBackward(_ storyId: String) {
        debug("swipeBackward", storyId)
        super.reportSwipeBackward(storyId)
    }
    
    override func reportImpression(_ storyId: String) {
        debug("impression", storyId)
        super.reportImpression(storyId)
    }
    
    override func reportViewDuration(_ storyId: String, duration: TimeInterval) {
        debug("viewDuration", storyId, "\(duration)", "sec")
        super.reportViewDuration(storyId, duration: duration)
    }
    
    private func debug(_ event: String...) {
        print("StorySDK.StoriesVC > Debug:", event.joined(separator: " "))
    }
}
