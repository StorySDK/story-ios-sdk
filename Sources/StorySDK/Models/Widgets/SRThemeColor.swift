//
//  SRThemeColor.swift
//  
//
//  Created by Aleksei Cherepanov on 23.05.2022.
//

import UIKit

enum SRThemeColor: Decodable {
    case purple, blue, darkBlue, white, green, orange, orangeRed, yellow
    case black, red, grey, custom(String)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value {
        case "purple": self = .purple
        case "blue": self = .blue
        case "darkBlue": self = .darkBlue
        case "white": self = .white
        case "green": self = .green
        case "orange": self = .orange
        case "orangeRed": self = .orangeRed
        case "yellow": self = .yellow
        case "black": self = .black
        case "red": self = .red
        case "grey": self = .grey
        default: self = .custom(value)
        }
    }
    
    var color: UIColor {
        switch self {
        case .purple: // #ae13ab
            return UIColor(red: 0.68, green: 0.07, blue: 0.67, alpha: 1.00)
        case .blue: // #00b2ff
            return UIColor(red: 0.00, green: 0.70, blue: 1.00, alpha: 1.00)
        case .darkBlue: // #366efe
            return UIColor(red: 0.21, green: 0.43, blue: 1.00, alpha: 1.00)
        case .white: // #ffffff
            return UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00)
        case .green: // #44d937
            return UIColor(red: 0.27, green: 0.85, blue: 0.22, alpha: 1.00)
        case .orange: // #ffa93d
            return UIColor(red: 1.00, green: 0.66, blue: 0.24, alpha: 1.00)
        case .orangeRed: // #ff4c25
            return UIColor(red: 1.00, green: 0.30, blue: 0.15, alpha: 1.00)
        case .yellow: // #f3cc00
            return UIColor(red: 0.95, green: 0.80, blue: 0.00, alpha: 1.00)
        case .black: // #05051d
            return UIColor(red: 0.02, green: 0.02, blue: 0.11, alpha: 1.00)
        case .red: // #d62727
            return UIColor(red: 0.84, green: 0.15, blue: 0.15, alpha: 1.00)
        case .grey: // #dddbde
            return UIColor(red: 0.87, green: 0.86, blue: 0.87, alpha: 1.00)
        case .custom:
            return .white
        }
    }
    
    var cgColor: CGColor { color.cgColor }
    
    var gradient: [UIColor] {
        switch self {
        case .purple:
            let from = UIColor(red: 0.68, green: 0.07, blue: 0.67, alpha: 1.00)
            let to = UIColor(red: 0.54, green: 0.05, blue: 0.92, alpha: 1.00)
            return [from, to]
        default:
            let color = self.color
            return [color, color]
        }
    }
}
