//
//  SRStoryDataStorage.swift
//  
//
//  Created by Aleksei Cherepanov on 13.05.2022.
//

import UIKit
import Combine

public protocol SRStoryDataStorage: AnyObject {
    var numberOfItems: Int { get }
    var onReloadData: (() -> Void)? { get set }
    var onErrorReceived: ((Error) -> Void)? { get set }
    func setupCell(_ cell: SRStoryCollectionCell, index: Int)
    func load(app: StoryApp)
}

public protocol SRStoryCollectionCell: AnyObject {
    var title: String? { get set }
    var image: UIImage? { get set }
    var cancelable: Cancellable? { get set }
    func setupStyle(_ style: SRCollectionCellStyle)
}

public struct SRCollectionCellStyle {
    /// Border gradient color for new stories
    var newBorderColors: [UIColor] = [
        UIColor(red: 1.0, green: 0.0, blue: 0.6, alpha: 1.0), // #FF0198
        UIColor(red: 0.73, green: 0.04, blue: 0.88, alpha: 1.0), // #B90AE0
    ]
    /// Border gradient color for viewew stories
    var normalBorderColors: [UIColor] = [
        UIColor(white: 0.91, alpha: 1.0),
        UIColor(white: 0.91, alpha: 1.0),
    ]
    /// Image corner radius as part of image height
    var corderRadius: CGFloat = 0.5
    /// Image size ratio
    var imageRatio: CGFloat = 1
    /// Display title inside the image view or outside above the image
    var isTitleInside: Bool = false
    /// Title font
    var font: UIFont = .systemFont(ofSize: 10, weight: .semibold)
    /// Cell background
    /// TODO: Maybe we need to cut border layer to avoid this declaration
    var backgroundColor: UIColor = .systemBackground
}
