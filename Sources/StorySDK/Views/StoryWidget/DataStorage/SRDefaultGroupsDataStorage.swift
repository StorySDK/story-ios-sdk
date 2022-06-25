//
//  SRDefaultGroupsDataStorage.swift
//  
//
//  Created by Aleksei Cherepanov on 13.05.2022.
//

import UIKit
import Combine

public class SRDefaultGroupsDataStorage: SRGroupsDataStorage {
    public var numberOfItems: Int { groups.count }
    public var onReloadData: (() -> Void)?
    public var onErrorReceived: ((Error) -> Void)?
    public var onPresentGroup: ((Int) -> Void)?
    
    private(set) public var groups: [SRStoryGroup] = []
    private(set) var groupsStyle: SRAppGroupViewSettings {
        didSet { cellConfg.update(settings: groupsStyle) }
    }
    private let storySdk: StorySDK
    var app: SRStoryApp? { storySdk.app }
    var cellConfg: SRCollectionCellStyle = .init()
    
    public init(sdk: StorySDK = .shared) {
        self.storySdk = sdk
        self.groupsStyle = sdk.app?.settings.groupView.ios ?? .circle
        cellConfg.update(settings: groupsStyle)
    }
    
    public func load() {
        groups = []
        loadApp { [weak self] _ in
            self?.storySdk.getGroups { result in
                switch result {
                case .success(let groups):
                    self?.groups = groups.filter { $0.active }
                    self?.onReloadData?()
                case .failure(let error):
                    self?.onErrorReceived?(error)
                }
            }
        }
    }
    
    public func setupLayout(_ layout: SRGroupsLayout) {
        switch groupsStyle {
        case .circle, .square:
            layout.updateSpacing(10)
            layout.updateItemSize(.init(width: 90, height: 90))
        case .bigSquare:
            layout.updateSpacing(10)
            layout.updateItemSize(.init(width: 90, height: 90))
        case .rectangle:
            layout.updateSpacing(10)
            layout.updateItemSize(.init(width: 72, height: 90))
        }
        layout.invalidateLayout()
    }
    
    public func setupCell(_ cell: SRGroupsCollectionCell, index: Int) {
        guard let group = group(with: index) else { return }
        cell.isPresented = storySdk.userDefaults.isPresented(group: group.id)
        cell.setupStyle(cellConfg)
        cell.title = group.title
        guard let url = group.imageUrl else { return }
        cell.cancelable = storySdk.imageLoader.load(
            url,
            size: groupsStyle.iconSize,
            scale: cell.contentsScale
        ) { [weak self, weak cell] result in
            switch result {
            case .success(let image): cell?.image = image
            case .failure(let error): self?.onErrorReceived?(error)
            }
        }
    }
    
    public func group(with index: Int) -> SRStoryGroup? {
        guard index < groups.count else { return nil } // In case if we trying to update cells while stories are reloading
        return groups[index]
    }
    
    public func didTap(index: Int) {
        guard let group = group(with: index) else { return }
        storySdk.userDefaults.didPresent(group: group.id)
        onReloadData?()
        onPresentGroup?(index)
    }
    
    func loadApp(_ completion: @escaping (SRStoryApp) -> Void) {
        if let app = app {
            completion(app)
        } else {
            storySdk.getApp { [weak self] result in
                switch result {
                case .success(let app):
                    self?.groupsStyle = app.settings.groupView.ios
                    completion(app)
                case .failure(let error):
                    self?.onErrorReceived?(error)
                }
            }
        }
    }
}

extension SRAppGroupViewSettings {
    var iconSize: CGSize {
        switch self {
        case .circle, .square:
            return .init(width: 64, height: 64)
        case .bigSquare:
            return .init(width: 90, height: 90)
        case .rectangle:
            return .init(width: 72, height: 90)
        }
    }
}
