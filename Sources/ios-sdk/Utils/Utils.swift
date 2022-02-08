//
//  Utils.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 04.02.2022.
//

import UIKit
import AVFoundation

class Utils: NSObject {
    static func getColor(_ stringValue: String) -> UIColor {
        if stringValue.contains("#") {
            return UIColor(hexString: stringValue)
        }
        else if stringValue.contains("rgb") {
            return UIColor(rgbString: stringValue)
        }
        else {
            return .white
        }
    }
    
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
        case "blue":
            return blue
        case "darkBlue":
            return darkBlue
        case "white":
            return white
        case "green":
            return green
        case "orange":
            return orange
        case "orangeRed":
            return orangeRed
        case "yellow":
            return yellow
        case "black":
            return black
        case "red":
            return red
        case "grey":
            return gray
        default:
            return .white
        }
    }
    
    static func getLabelGradientColor(bounds: CGRect, gradientLayer : CAGradientLayer) -> UIColor? {
        if bounds.size.width <= 0 || bounds.size.height <= 0 {
            return .white
        }
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        //create UIImage by rendering gradient layer.
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //get gradient UIcolor from gradient UIImage
        return UIColor(patternImage: image!)
    }

    static func getFont(fontFamily: String, fontSize: CGFloat, fontParams: FontParamsValue) -> UIFont {
        var fontName = "Roboto-Regular"
        switch fontFamily {
        case "Arial":
            fontName = "ArialMT"
            if fontParams.style == "italic" {
                fontName = "Arial-ItalicMT"
            }
            if fontParams.weight > 400 {
                fontName = "Arial-BoldMT"
                if fontParams.style == "italic" {
                    fontName = "Arial-BoldItalicMT"
                }
            }

        case "Calibri":
            fontName = "Calibri"
            if fontParams.style == "italic" {
                fontName = "Calibri-Italic"
            }
            if fontParams.weight > 400 {
                fontName = "Calibri-Bold"
                if fontParams.style == "italic" {
                    fontName = "Cailibri-BoldItalic"
                }
            }
            else if fontParams.weight < 400 {
                fontName = "Calibri-Light"
                if fontParams.style == "italic" {
                    fontName = "Calibri-LightItalic"
                }
            }
        case "Impact":
            fontName = "Impact"
        case "Lobster":
            fontName = "Lobster-Regular"
//            if fontParams.style == "italic" {
//                fontName = "LobsterTwo-Italic"
//            }
//            if fontParams.weight > 400 {
//                fontName = "LobsterTwo-Bold"
//                if fontParams.style == "italic" {
//                    fontName = "LobsterTwo-BoldItalic"
//                }
//            }
        case "Roboto":
            fontName = "Roboto-Regular"
            if fontParams.style == "italic" {
                fontName = "Roboto-Italic"
            }
            if fontParams.weight > 400 {
                fontName = "Roboto-Bold"
                if fontParams.style == "italic" {
                    fontName = "Roboto-BoldItalic"
                }
            }
            else if fontParams.weight < 400 {
                fontName = "RobotoCondensed-Light"
                if fontParams.style == "italic" {
                    fontName = "RobotoCondensed-LightItalic"
                }
            }
        default:
            break
        }
        
        if let font = UIFont(name: fontName, size: fontSize) {
            return font
        }
        else {
            return UIFont.systemFont(ofSize: fontSize)
        }
    }
    
    static func getTextAlignment(_ alignment: String) -> NSTextAlignment {
        if alignment == "left" {
            return .left
        }
        else if alignment == "right" {
            return .right
        }
        else {
            return .center
        }
    }
}
