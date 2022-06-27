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
    let gestureRecognizer = SRStoriesGestureRecognizer()
    
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
        dataStorage.gestureRecognizer = gestureRecognizer
        
        widgetResponder.progress = progress
        widgetResponder.analytics = analytics
        
        progress.analytics = analytics
        
        analytics.dataStorage = dataStorage
        
        gestureRecognizer.dataStorage = dataStorage
        gestureRecognizer.widgetResponder = widgetResponder
        gestureRecognizer.progress = progress
    }
    
    // MARK: - Data Storage
    
    var numberOfItems: Int { dataStorage.numberOfItems }
    var onReloadData: (() -> Void)? {
        get { dataStorage.onReloadData }
        set { dataStorage.onReloadData = newValue }
    }
    var onGotEmptyGroup: (() -> Void)? {
        get { dataStorage.onGotEmptyGroup }
        set { dataStorage.onGotEmptyGroup = newValue }
    }
    var onErrorReceived: ((Error) -> Void)? {
        get { dataStorage.onErrorReceived }
        set { dataStorage.onErrorReceived = newValue }
    }
    var onUpdateHeader: ((HeaderInfo) -> Void)? {
        get { dataStorage.onUpdateHeader }
        set { dataStorage.onUpdateHeader = newValue }
    }
    var presentTalkAbout: ((SRTalkAboutViewController) -> Void)? {
        get { widgetResponder.presentTalkAbout }
        set { widgetResponder.presentTalkAbout = newValue }
    }
    var containerFrame: SRRect {
        get { widgetResponder.containerFrame }
        set { widgetResponder.containerFrame = newValue }
    }
    var resignFirstResponder: (() -> Void)? {
        get { gestureRecognizer.resignFirstResponder }
        set { gestureRecognizer.resignFirstResponder = newValue }
    }
    
    func loadStories(group: SRStoryGroup) {
        dataStorage.loadStories(group: group)
    }
    
    func setupCell(_ cell: SRStoryCell, index: Int) {
        dataStorage.setupCell(cell, index: index)
    }
    
    func willDisplay(_ cell: SRStoryCell, index: Int) {
        dataStorage.willDisplay(cell, index: index)
    }
    
    func endDisplaying(_ cell: SRStoryCell, index: Int) {
        dataStorage.endDisplaying(cell, index: index)
    }
    
    // MARK: - Progress
    
    var onProgressUpdated: ((Float) -> Void)? {
        get { progress.onProgressUpdated }
        set { progress.onProgressUpdated = newValue }
    }
    
    var onScrollToStory: ((Int, Bool) -> Void)? {
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
    
    func willBeginTransition() {
        progress.willBeginTransition()
    }
    
    func didEndTransition() {
        progress.didEndTransition()
    }
}
