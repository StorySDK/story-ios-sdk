//
//  Utils.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 04.02.2022.
//

import UIKit
import AVFoundation

class Utils: NSObject {
    static func getGradient(frame: CGRect, colors: [UIColor], points: [CGPoint]) -> CAGradientLayer {
        let l = CAGradientLayer()
        l.frame = frame
        l.colors = [colors[0].cgColor, colors[1].cgColor]
        l.startPoint = points[0]
        l.endPoint = points[1]

        return l
    }
    
    static func getSolidColor(_ stringValue: String) -> UIColor {
        switch stringValue {
        case "blue": return blue
        case "darkBlue": return darkBlue
        case "white": return white
        case "green": return green
        case "orange": return orange
        case "orangeRed": return orangeRed
        case "yellow": return yellow
        case "black": return black
        case "red": return red
        case "grey": return gray
        default: return .white
        }
    }
}
