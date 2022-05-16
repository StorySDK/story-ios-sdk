//
//  SRDefaultStoryDataStorage.swift
//  
//
//  Created by Aleksei Cherepanov on 13.05.2022.
//

import UIKit
import Combine

public class SRDefaultStoryDataStorage: SRStoryDataStorage {
    public var numberOfItems: Int { groups.count }
    public var onReloadData: (() -> Void)?
    public var onErrorReceived: ((Error) -> Void)?
    
    private(set) var groups: [StoryGroup] = []
    private(set) var app: StoryApp?
    private(set) var groupsStyle: AppGroupViewSettings = .circle {
        didSet { cellConfg.update(settings: groupsStyle) }
    }
    private let storySdk: StorySDK
    var cellConfg: SRCollectionCellStyle = .init()
    
    public init(sdk: StorySDK = .shared) {
        self.storySdk = sdk
    }
    
    public func load() {
        if app == nil { loadApp() }
        groups = []
        storySdk.getGroups { [weak self] result in
            switch result {
            case .success(let groups):
                self?.groups = groups
                self?.onReloadData?()
            case .failure(let error):
                self?.onErrorReceived?(error)
            }
        }
    }
    
    public func setupLayout(_ layout: SRStoryLayout) {
        switch groupsStyle {
        case .circle, .square:
            layout.updateSpacing(10)
            layout.updateItemSize(.init(width: 90, height: 90))
        case .bigSquare:
            layout.updateSpacing(0)
            layout.updateItemSize(.init(width: 90, height: 90))
        case .rectangle:
            layout.updateSpacing(0)
            layout.updateItemSize(.init(width: 72, height: 90))
        }
        layout.invalidateLayout()
    }
    
    public func setupCell(_ cell: SRStoryCollectionCell, index: Int) {
        guard let story = group(with: index) else { return }
        cell.setupStyle(cellConfg)
        cell.title = story.title
        guard let url = story.imageUrl else { return }
        cell.cancelable = storySdk.imageLoader.load(url) { [weak self, weak cell] result in
            switch result {
            case .success(let image): cell?.image = image
            case .failure(let error): self?.onErrorReceived?(error)
            }
        }
    }
    
    public func group(with index: Int) -> StoryGroup? {
        guard index < groups.count else { return nil } // In case if we trying to update cells while reloading stories
        return groups[index]
    }
    
    func loadApp() {
        storySdk.getApp { [weak self] result in
            switch result {
            case .success(let app):
                self?.app = app
                self?.groupsStyle = app.settings.groupView.ios
                self?.onReloadData?()
            case .failure(let error):
                self?.onErrorReceived?(error)
            }
        }
    }
}
