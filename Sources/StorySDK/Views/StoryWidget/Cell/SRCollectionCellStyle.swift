//
//  File.swift
//  
//
//  Created by Aleksei Cherepanov on 13.05.2022.
//

import UIKit

public struct SRCollectionCellStyle {
    /// Border gradient color for new stories
    public var newBorderColors: [UIColor] = [
        UIColor(red: 1.0, green: 0.0, blue: 0.6, alpha: 1.0), // #FF0198
        UIColor(red: 0.73, green: 0.04, blue: 0.88, alpha: 1.0), // #B90AE0
    ]
    /// Border gradient color for viewew stories
    public var normalBorderColors: [UIColor] = [UIColor(white: 0.91, alpha: 1.0)]
    /// Image corner radius as part of image height
    public var corderRadius: CGFloat = 0.5
    /// Display title inside the image view or outside above the image
    public var isTitleInside: Bool = false
    /// Title font
    public var font: UIFont = .systemFont(ofSize: 10, weight: .semibold)
    /// Cell background
    /// TODO: Maybe we need to cut border layer to avoid this declaration
    public var backgroundColor: UIColor = .systemBackground
    
    
    public init(
        newBorderColors: [UIColor] = [
            UIColor(red: 1.0, green: 0.0, blue: 0.6, alpha: 1.0), // #FF0198
            UIColor(red: 0.73, green: 0.04, blue: 0.88, alpha: 1.0), // #B90AE0
        ],
        normalBorderColors: [UIColor] = [UIColor(white: 0.91, alpha: 1.0)],
        corderRadius: CGFloat = 0.5,
        isTitleInside: Bool = false,
        font: UIFont = .systemFont(ofSize: 10, weight: .semibold),
        backgroundColor: UIColor = .systemBackground
    ) {
        self.newBorderColors = newBorderColors
        self.normalBorderColors = normalBorderColors
        self.corderRadius = corderRadius
        self.isTitleInside = isTitleInside
        self.font = font
        self.backgroundColor = backgroundColor
    }
    
    public mutating func update(settings: AppGroupViewSettings) {
        switch settings {
        case .circle:
            corderRadius = 0.5
            isTitleInside = false
        case .square:
            corderRadius = 10.0 / 64.0
            isTitleInside = false
        case .bigSquare:
            corderRadius = 10.0 / 82.0
            isTitleInside = true
        case .rectangle:
            corderRadius = 10.0 / 82.0
            isTitleInside = true
        }
    }
}
