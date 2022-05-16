//
//  SRStoryDataStorage.swift
//  
//
//  Created by Aleksei Cherepanov on 13.05.2022.
//

import UIKit
import Combine

public protocol SRStoryDataStorage: AnyObject {
    /// Number of groups in the app
    var numberOfItems: Int { get }
    /// Groups collection has been updated
    var onReloadData: (() -> Void)? { get set }
    /// An error has been received
    var onErrorReceived: ((Error) -> Void)? { get set }
    /// Configures story layout according used groups style
    func setupLayout(_ layout: SRStoryLayout)
    /// Configures cell with a group with index
    func setupCell(_ cell: SRStoryCollectionCell, index: Int)
    /// Returns group with index
    func group(with index: Int) -> StoryGroup?
    /// Loads groups
    func load()
}

public protocol SRStoryCollectionCell: AnyObject {
    var title: String? { get set }
    var image: UIImage? { get set }
    var cancelable: Cancellable? { get set }
    func setupStyle(_ style: SRCollectionCellStyle)
}

public protocol SRStoryLayout: AnyObject {
    func updateSpacing(_ spacing: CGFloat)
    func updateItemSize(_ size: CGSize)
    func invalidateLayout()
}
