//
//  SRDefaultAnalyticsController.swift
//  
//
//  Created by Aleksei Cherepanov on 07.06.2022.
//

import Foundation

final class SRDefaultAnalyticsController: SRAnalyticsController {
    struct StoryInfo {
        var index: Int
        var id: String
        var openTime: Date = .init()
    }
    let storySdk: StorySDK
    var group: SRStoryGroup? { dataStorage?.group }
    var groupOpenTime: Date?
    weak var dataStorage: SRStoriesDataStorage?
    private var currentStory: StoryInfo?
    
    // TODO: Move flags to a group
    private var isStarted: Bool
    private var isFinished: Bool
    
    init(sdk: StorySDK = .shared) {
        storySdk = sdk
        isStarted = false
        isFinished = false
    }
    
    func sendReaction(_ reaction: SRStatistic, completion: ((Result<Bool, Error>) -> Void)? = nil) {
        var reaction = reaction
        reaction.groupId = group?.id
        storySdk.sendStatistic(reaction) { result in
            switch result {
            case .success:
                logger.debug("\(reaction)", logger: .stories)
            case .failure(let error):
                logger.error(error.localizedDescription, logger: .stories)
            }
            completion?(result)
        }
    }
    
    func sendWidgetReaction(_ reaction: SRStatistic,
                            widget: SRInteractiveWidgetView) {
        let widgetId = widget.data.id
        var reaction = reaction
        reaction.storyId = widget.story.id
        reaction.widgetId = widgetId
        reaction.locale = storySdk.configuration.language
        
        sendReaction(reaction) { [weak storySdk] result in
            guard case .success = result else { return }
            storySdk?.userDefaults.setReaction(widgetId: widgetId, value: reaction.value)
        }
    }
    
    func reportGroupOpen() {
        sendReaction(.init(type: .open))
        groupOpenTime = Date()
        if let id = group?.id { storySdk.userDefaults.didPresent(group: id) }
        guard let first = dataStorage?.storyId(atIndex: 0) else { return }
        reportStoryOpen(.init(index: 0, id: first))
    }
    
    func reportGroupClose() {
        currentStory.map(reportStoryClose)
        sendReaction(.init(type: .close))
        guard let time = groupOpenTime else { return }
        let duration = -time.timeIntervalSinceNow
        reportViewDuration(duration: duration)
    }
    
    func reportStoryOpen(_ info: StoryInfo) {
        sendReaction(.init(type: .open, storyId: info.id))
        currentStory = info
    }
    
    func reportStoryClose(_ info: StoryInfo) {
        let duration = -info.openTime.timeIntervalSinceNow
        if duration > 2 { reportImpression(info.id) }
        reportViewDuration(info.id, duration: duration)
        sendReaction(.init(type: .close, storyId: info.id))
    }
    
    func storyDidChanged(to index: Int, byUser: Bool) {
        guard let id = dataStorage?.storyId(atIndex: index) else { return }
        guard let old = currentStory else {
            reportStoryOpen(.init(index: index, id: id))
            return
        }
        guard old.index != index else { return }
        reportStoryClose(old)
        reportStoryOpen(.init(index: index, id: id))
        guard byUser else { return }
        if old.index > index {
            reportSwipeBackward(from: old.id)
        } else {
            reportSwipeForward(from: old.id)
        }
    }
    
    func reportSwipeForward(from storyId: String?) {
        sendReaction(.init(type: .next, storyId: storyId))
    }
    
    func reportSwipeBackward(from storyId: String?) {
        sendReaction(.init(type: .back, storyId: storyId))
    }
    
    func reportImpression(_ storyId: String) {
        sendReaction(.init(type: .impression, storyId: storyId))
    }
    
    func reportViewDuration(_ storyId: String? = nil, duration: TimeInterval) {
        sendReaction(.init(type: .duration, storyId: storyId, value: "\(duration)"))
    }
    
    func reportQuizStart(time: Date) {
        if !isStarted {
            isStarted = true
            
            let value = DateFormatter.rfc3339.string(from: Date())
            sendReaction(.init(type: .start, value: value))
        }
    }
    
    func reportQuizFinish(time: Date) {
        if isStarted && !isFinished {
            isFinished = true
            
            let value = DateFormatter.rfc3339.string(from: Date())
            sendReaction(.init(type: .finish, value: value))
        }
    }
}
