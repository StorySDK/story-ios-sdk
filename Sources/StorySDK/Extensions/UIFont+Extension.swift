//
//  UIFont+Extension.swift
//  StorySDK
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
            } else {
                return font
            }
        } else {
            if let weight = weight {
                return UIFont.systemFont(ofSize: size, weight: weight)
            } else {
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
        guard !fontsRegistered else { return }
        guard let fontURLs = Bundle.module.urls(forResourcesWithExtension: "ttf", subdirectory: nil) else { return }
        fontURLs.forEach({ CTFontManagerRegisterFontsForURL($0 as CFURL, .process, nil) })
        fontsRegistered = true
    }
    
    static func regular(ofSize size: CGFloat) -> UIFont {
        getFont(name: "Inter-Regular", size: size)
    }
    static func semibold(ofSize size: CGFloat) -> UIFont {
        getFont(name: "Inter-SemiBold", size: size)
    }
    static func bold(ofSize size: CGFloat) -> UIFont {
        getFont(name: "Inter-Bold", size: size)
    }
    static func medium(ofSize size: CGFloat) -> UIFont {
        getFont(name: "Inter-Medium", size: size)
    }
}
