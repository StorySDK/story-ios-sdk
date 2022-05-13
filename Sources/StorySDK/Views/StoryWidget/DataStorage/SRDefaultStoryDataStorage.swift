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
    private let storySdk: StorySDK
    
    private var locale: String { storySdk.configuration.language }
    private var defaulLocale: String? { app?.localization.defaultLocale }
    
    public init(sdk: StorySDK = .shared) {
        self.storySdk = sdk
    }
    
    public func load(app: StoryApp) {
        groups = []
        storySdk.getGroups(appId: app.id) { [weak self] result in
            switch result {
            case .success(let groups):
                self?.groups = groups
                self?.onReloadData?()
            case .failure(let error):
                self?.onErrorReceived?(error)
            }
        }
    }
    
    public func setupCell(_ cell: SRStoryCollectionCell, index: Int) {
        guard let story = group(with: index) else { return } 
        cell.title = story.getTitle(locale: locale, defaultLocale: defaulLocale)
        if let url = story.getImageURL(locale: locale, defaultLocale: defaulLocale) {
            cell.cancelable = storySdk.imageLoader.load(url) { [weak self, weak cell] result in
                switch result {
                case .success(let image): cell?.image = image
                case .failure(let error): self?.onErrorReceived?(error)
                }
            }
        }
    }
    
    public func group(with index: Int) -> StoryGroup? {
        guard index < groups.count else { return nil } // In case if we trying to update cells while reloading stories
        return groups[index]
    }
}
