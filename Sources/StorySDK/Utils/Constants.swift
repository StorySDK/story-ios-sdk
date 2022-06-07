//
//  Constants.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 03.02.2022.
//

import UIKit

// public typealias Json = [String: Any]

extension TimeInterval {
    static let animationsDuration: TimeInterval = 0.2
}

/// Коэффициент масштабирования по горизонтали. Вычисляется при показе виджетов
var xScaleFactor: CGFloat = 1
/// Коэффициент масштабирования по вертикали. Вычисляется при показе виджетов
var yScaleFactor: CGFloat = 1
/// Высота верхней вьюшки (где картинка и название Story)
let topViewHeight: CGFloat = 64

extension NSNotification.Name {
    static let disableSwipe = NSNotification.Name(rawValue: "DisableSwipe")
}
