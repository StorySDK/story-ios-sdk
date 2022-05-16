//
//  SRStoryViewModel.swift
//  
//
//  Created by Aleksei Cherepanov on 13.05.2022.
//

import Foundation

class SRStoryViewModel {
    var numberOfItems: Int { dataStorage.numberOfItems }
    var onReloadData: (() -> Void)? {
        get { dataStorage.onReloadData }
        set { dataStorage.onReloadData = newValue }
    }
    var onErrorReceived: ((Error) -> Void)? {
        get { dataStorage.onErrorReceived }
        set { dataStorage.onErrorReceived = newValue }
    }
    let dataStorage: SRStoryDataStorage
    
    init(dataStorage: SRStoryDataStorage) {
        self.dataStorage = dataStorage
    }
    
    func load() {
        dataStorage.load()
    }
    
    func setupLayout(_ layout: SRStoryLayout) {
        dataStorage.setupLayout(layout)
    }
    
    func setupCell(_ cell: SRStoryCollectionCell, index: Int) {
        dataStorage.setupCell(cell, index: index)
    }
    
    func group(with index: Int) -> StoryGroup? {
        dataStorage.group(with: index)
    }
}
