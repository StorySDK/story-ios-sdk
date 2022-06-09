//
//  SRStoriesViewModel.swift
//  
//
//  Created by Aleksei Cherepanov on 19.05.2022.
//

import Foundation

final class SRStoriesViewModel {
    let dataStorage: SRStoriesDataStorage
    let progress: SRProgressController
    let widgetResponder: SRWidgetResponder
    let analytics: SRAnalyticsController
    
    init(dataStorage: SRStoriesDataStorage,
         progress: SRProgressController,
         widgetResponder: SRWidgetResponder,
         analytics: SRAnalyticsController) {
        self.dataStorage = dataStorage
        self.progress = progress
        self.widgetResponder = widgetResponder
        self.analytics = analytics
        dataStorage.progress = progress
        dataStorage.analytics = analytics
        dataStorage.widgetResponder = widgetResponder
        widgetResponder.progress = progress
        widgetResponder.analytics = analytics
        progress.analytics = analytics
        analytics.dataStorage = dataStorage
    }
    
    // MARK: - Data Storage
    
    var numberOfItems: Int { dataStorage.numberOfItems }
    var onReloadData: (() -> Void)? {
        get { dataStorage.onReloadData }
        set { dataStorage.onReloadData = newValue }
    }
    var onErrorReceived: ((Error) -> Void)? {
        get { dataStorage.onErrorReceived }
        set { dataStorage.onErrorReceived = newValue }
    }
    var onUpdateHeader: ((HeaderInfo) -> Void)? {
        get { dataStorage.onUpdateHeader }
        set { dataStorage.onUpdateHeader = newValue }
    }
    var onUpdateTransformNeeded: ((Float) -> Void)? {
        get { widgetResponder.onUpdateTransformNeeded }
        set { widgetResponder.onUpdateTransformNeeded = newValue }
    }
    var containerFrame: SRRect {
        get { widgetResponder.containerFrame }
        set { widgetResponder.containerFrame = newValue }
    }
    
    func loadStories(group: StoryGroup) {
        dataStorage.loadStories(group: group)
    }
    
    func setupCell(_ cell: SRStoryCell, index: Int) {
        dataStorage.setupCell(cell, index: index)
    }
    
    // MARK: - Progress
    
    var onProgressUpdated: ((Float) -> Void)? {
        get { progress.onProgressUpdated }
        set { progress.onProgressUpdated = newValue }
    }
    
    var onScrollToStory: ((Int) -> Void)? {
        get { progress.onScrollToStory }
        set { progress.onScrollToStory = newValue }
    }
    var onScrollCompeted: (() -> Void)? {
        get { progress.onScrollCompeted }
        set { progress.onScrollCompeted = newValue }
    }
    
    func willBeginDragging() {
        progress.willBeginDragging()
    }
    
    func didEndDragging() {
        progress.didEndDragging()
    }
    
    func didScroll(offset: Float, contentWidth: Float) {
        progress.didScroll(offset: offset, contentWidth: contentWidth)
    }
    
    func setupProgress(_ component: SRProgressComponent) {
        progress.setupProgress(component)
    }
    
    func startAutoscrolling() {
        progress.startAutoscrolling()
    }
    
    func pauseAutoscrolling() {
        progress.pauseAutoscrolling()
    }
    
    func reportGroupOpen() {
        analytics.reportGroupOpen()
    }
    
    func reportGroupClose() {
        analytics.reportGroupClose()
    }
}
