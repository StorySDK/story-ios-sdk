//
//  BackgroundType.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 10.04.2022.
//

import UIKit

#warning("Надо разобраться с видео для background")
/// Types of backround
///
/// Possible variants:
/// - color - solid color (from hex or prepared color)
/// - gradient - gradient form two hex colors or prepared color "purple"
/// - null - no color
public enum BackgroundType {
    case color(ColorValue),
         gradient(GradientValue),
         null(String)
}
