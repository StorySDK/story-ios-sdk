//
//  UIFont+Extension.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 07.02.2022.
//

import UIKit

extension UIFont {

    class func getFont(name: String, size: CGFloat, weight: UIFont.Weight? = nil) -> UIFont {
        registerFontsIfNeeded()
        if let font = UIFont(name: name, size: size) {
            
            if let weight = weight {
                return font.withWeight(weight)
            }
            else {
                return font
            }
        }
        else {
            if let weight = weight {
                return UIFont.systemFont(ofSize: size, weight: weight)
            }
            else {
                return UIFont.systemFont(ofSize: size)
            }
        }
    }

    private func withWeight(_ weight: UIFont.Weight) -> UIFont {
        var attributes = fontDescriptor.fontAttributes
        var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]

        traits[.weight] = weight

        attributes[.name] = nil
        attributes[.traits] = traits
        attributes[.family] = familyName

        let descriptor = UIFontDescriptor(fontAttributes: attributes)

        return UIFont(descriptor: descriptor, size: pointSize)
    }

    private static var fontsRegistered: Bool = false

    static func registerFontsIfNeeded() {
        let frameworkBundle = Bundle(for: StorySDK.self)
//        let frameworkBundle = Bundle.main
        guard !fontsRegistered, let fontURLs = frameworkBundle.urls(forResourcesWithExtension: "ttf", subdirectory: nil)
        else { return }

        fontURLs.forEach({ CTFontManagerRegisterFontsForURL($0 as CFURL, .process, nil) })
        fontsRegistered = true
    }
}
