//
//  SRGroupsDataStorage.swift
//  
//
//  Created by Aleksei Cherepanov on 13.05.2022.
//

import UIKit
import Combine

public protocol SRGroupsDataStorage: AnyObject {
    /// Cell class to register in the collection view
    var cellClass: SRGroupsCollectionCell.Type { get }
    /// Array of loaded groups
    var groups: [SRStoryGroup] { get }
    /// Number of groups in the app
    var numberOfItems: Int { get }
    /// Groups collection has been updated
    var onReloadData: (() -> Void)? { get set }
    /// An error has been received
    var onErrorReceived: ((Error) -> Void)? { get set }
    /// Index of the group should be presented to a user
    var onPresentGroup: ((Int) -> Void)? { get set }
    /// When all groups are loaded
    var onGroupsLoaded: (() -> Void)? { get set }
    /// When all groups are closed
    var onGroupClosed: (() -> Void)? { get set }
    /// When external custom widget action should be call
    var onMethodCall: ((String?) -> Void)? { get set }
    /// Configures story layout according used groups style
    func setupLayout(_ layout: SRGroupsLayout)
    /// Configures cell with a group with index
    func setupCell(_ cell: SRGroupsCollectionCell, index: Int)
    /// User has tapped on the group
    func didTap(index: Int)
    /// Loads groups
    func load()
    /// Reloads app & groups
    func reload()
}

public protocol SRGroupsCollectionCell: UICollectionViewCell {
    var title: String? { get set }
    var image: UIImage? { get set }
    var isPresented: Bool { get set }
    var cancelable: Cancellable? { get set }
    var contentsScale: CGFloat { get }
    func setupStyle(_ style: SRCollectionCellStyle)
    
    func makeSkeletonCell()
}

extension SRGroupsCollectionCell {
    var contentsScale: CGFloat { UIScreen.main.scale }
}

public protocol SRGroupsLayout: AnyObject {
    func updateSpacing(_ spacing: CGFloat)
    func updateItemSize(_ size: CGSize)
    func invalidateLayout()
}
