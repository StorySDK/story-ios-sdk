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
    
    init(dataStorage: SRStoriesDataStorage,
         progress: SRProgressController,
         widgetResponder: SRWidgetResponder) {
        self.dataStorage = dataStorage
        self.progress = progress
        self.widgetResponder = widgetResponder
        dataStorage.progressController = progress
        dataStorage.widgetResponder = widgetResponder
        widgetResponder.progressController = progress
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
    
    func didInteract() {
        progress.didInteract()
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
}
