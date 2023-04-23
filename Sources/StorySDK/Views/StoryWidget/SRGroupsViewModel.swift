//
//  SRGroupsViewModel.swift
//  
//
//  Created by Aleksei Cherepanov on 13.05.2022.
//

import Foundation

final class SRGroupsViewModel {
    var cellClass: SRGroupsCollectionCell.Type { dataStorage.cellClass }
    var numberOfItems: Int { dataStorage.numberOfItems }
    var onReloadData: (() -> Void)? {
        get { dataStorage.onReloadData }
        set { dataStorage.onReloadData = newValue }
    }
    var onErrorReceived: ((Error) -> Void)? {
        get { dataStorage.onErrorReceived }
        set { dataStorage.onErrorReceived = newValue }
    }
    var onPresentGroup: ((Int) -> Void)? {
        get { dataStorage.onPresentGroup }
        set { dataStorage.onPresentGroup = newValue }
    }
    var groups: [SRStoryGroup] { dataStorage.groups }
    let dataStorage: SRGroupsDataStorage
    
    init(dataStorage: SRGroupsDataStorage) {
        self.dataStorage = dataStorage
    }
    
    func load() {
        dataStorage.load()
    }
    
    func reload() {
        dataStorage.reload()
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