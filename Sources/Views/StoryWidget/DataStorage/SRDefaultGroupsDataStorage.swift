//
//  SRDefaultGroupsDataStorage.swift
//  
//
//  Created by Aleksei Cherepanov on 13.05.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif
import Combine

open class SRDefaultGroupsDataStorage: SRGroupsDataStorage {
    open var cellClass: SRGroupsCollectionCell.Type { SRCollectionCell.self }
    public var numberOfItems: Int { groups.count }
    public var onReloadData: (() -> Void)?
    public var onErrorReceived: ((Error) -> Void)?
    public var onPresentGroup: ((Int) -> Void)?
    public var onGroupsLoaded: (() -> Void)?
    public var onGroupClosed: (() -> Void)?
    public var onMethodCall: ((String?) -> Void)?
    
    private(set) public var groups: [SRStoryGroup] = []
    private(set) var groupsStyle: SRAppGroupViewSettings = .bigSquare {
        didSet { cellConfig.update(settings: groupsStyle) }
    }
    private let storySdk: StorySDK
    
    private struct Sizes {
        static let spacing: CGFloat = 14.0
        static let groupSize: CGFloat = 94.0
    }
    
    var app: SRStoryApp? { storySdk.app }
    var cellConfig: SRCollectionCellStyle = .init()
    var presentedCancellable: Cancellable? {
        didSet { oldValue?.cancel() }
    }
    var presentedStories: [String: Bool] = [:] {
        didSet {
            onReloadData?()
        }
    }
    
    public init(sdk: StorySDK = .shared) {
        self.storySdk = sdk
        self.groupsStyle = sdk.app?.settings.groupView.ios ?? .circle
        cellConfig.update(settings: groupsStyle)
    }
    
    public func load() {
        groups = []
        loadApp { [weak self] _ in
            self?.storySdk.getGroups { result in
                switch result {
                case .success(let allGroups):
                    let activeGroups = self?.activeGroupsFilter(allGroups) ?? []
                    self?.groups = activeGroups
                    self?.updatePresentedStats(activeGroups)
                    
                    self?.onGroupsLoaded?()
                case .failure(let error):
                    self?.onErrorReceived?(error)
                }
            }
        }
    }
    
    public func reload() {
        groups = []
        reloadApp { [weak self] _ in
            self?.storySdk.getGroups { result in
                switch result {
                case .success(let allGroups):
                    let activeGroups = self?.activeGroupsFilter(allGroups) ?? []
                    self?.groups = activeGroups
                    self?.updatePresentedStats(activeGroups)
                    
                    self?.onGroupsLoaded?()
                case .failure(let error):
                    self?.onErrorReceived?(error)
                }
            }
        }
    }
    
    func activeGroupsFilter(_ allGroups: [SRStoryGroup]) -> [SRStoryGroup] {
        return allGroups.filter { $0.readyToShow() }.sorted()
    }
    
    open func setupLayout(_ layout: SRGroupsLayout) {
        switch groupsStyle {
        case .circle, .square:
            layout.updateSpacing(Sizes.spacing)
            layout.updateItemSize(.init(width: Sizes.groupSize, height: Sizes.groupSize))
        case .bigSquare:
            layout.updateSpacing(Sizes.spacing)
            layout.updateItemSize(.init(width: Sizes.groupSize, height: Sizes.groupSize))
        case .rectangle:
            layout.updateSpacing(Sizes.spacing)
            layout.updateItemSize(.init(width: 72, height: Sizes.groupSize))
        }
        layout.invalidateLayout()
    }
    
    open func setupCell(_ cell: SRGroupsCollectionCell, index: Int) {
        guard let group = group(with: index) else { return }
        
#if os(iOS)
        cell.isPresented = presentedStories[group.id] ?? false
        cell.setupStyle(cellConfig)
        
        //cell.title = group.title
        guard let url = group.imageUrl else {
            cell.title = group.title
            return
        }
        
        cell.cancelable = storySdk.imageLoader.load(
            url,
            size: groupsStyle.iconSize,
            scale: cell.contentsScale
        ) { [weak self, weak cell] result in
            cell?.title = group.title
            switch result {
            case .success(let image):
                cell?.image = image
            case .failure(let error):
                self?.onErrorReceived?(error)
            }
        }
#endif
    }
    
    public func group(with index: Int) -> SRStoryGroup? {
        guard index < groups.count else { return nil } // In case if we trying to update cells while stories are reloading
        return groups[index]
    }
    
    public func didTap(index: Int) {
        onPresentGroup?(index)
        onReloadData?()
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
    
    func reloadApp(_ completion: @escaping (SRStoryApp) -> Void) {
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
    
    func updatePresentedStats(_ groups: [SRStoryGroup]) {
        let set = Set<String>(groups.map(\.id))
        presentedCancellable = storySdk.userDefaults
            .presentedStoriesObserve(for: set)
            .assign(to: \.presentedStories, on: self)
    }
}

extension SRAppGroupViewSettings {
    var iconSize: CGSize {
        switch self {
        case .circle, .square:
            return .init(width: 64, height: 64)
        case .bigSquare:
            return .init(width: 94, height: 94)
        case .rectangle:
            return .init(width: 72, height: 94)
        }
    }
}
