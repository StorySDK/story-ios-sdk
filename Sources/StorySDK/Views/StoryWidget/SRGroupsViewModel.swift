//
//  SRGroupsViewModel.swift
//  
//
//  Created by Aleksei Cherepanov on 13.05.2022.
//

import Foundation

final class SRGroupsViewModel {
    var numberOfItems: Int { dataStorage.numberOfItems }
    var onReloadData: (() -> Void)? {
        get { dataStorage.onReloadData }
        set { dataStorage.onReloadData = newValue }
    }
    var onErrorReceived: ((Error) -> Void)? {
        get { dataStorage.onErrorReceived }
        set { dataStorage.onErrorReceived = newValue }
    }
    var onPresentGroup: ((StoryGroup) -> Void)? {
        get { dataStorage.onPresentGroup }
        set { dataStorage.onPresentGroup = newValue }
    }
    let dataStorage: SRGroupsDataStorage
    
    init(dataStorage: SRGroupsDataStorage) {
        self.dataStorage = dataStorage
    }
    
    func load() {
        dataStorage.load()
    }
    
    func setupLayout(_ layout: SRGroupsLayout) {
        dataStorage.setupLayout(layout)
    }
    
    func setupCell(_ cell: SRGroupsCollectionCell, index: Int) {
        dataStorage.setupCell(cell, index: index)
    }
    
    func didTap(index: Int) {
        dataStorage.didTap(index: index)
    }
}
