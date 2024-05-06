//
//  UIFont+Extension.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 07.02.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

extension StoryFont {
    class func getFont(name: String, size: CGFloat, weight: StoryFont.Weight? = nil) -> StoryFont {
        registerFontsIfNeeded()
        if name == "System" || name == "San Francisco" {
            return getSystemFont(size: size, weight: weight)
        }
        
        if let font = StoryFont(name: name, size: size) {
            if let weight = weight {
                return font.withWeight(weight)
            } else {
                return font
            }
        } else {
            return getSystemFont(size: size, weight: weight)
        }
    }
    
    class func getSystemFont(size: CGFloat, weight: StoryFont.Weight? = nil) -> StoryFont {
        if let weight = weight {
            return StoryFont.systemFont(ofSize: size, weight: weight)
        } else {
            return StoryFont.systemFont(ofSize: size)
        }
    }

    private func withWeight(_ weight: StoryFont.Weight) -> StoryFont {
        var attributes = fontDescriptor.fontAttributes
        var traits = (attributes[.traits] as? [StoryFontDescriptor.TraitKey: Any]) ?? [:]

        traits[.weight] = weight

        attributes[.name] = nil
        attributes[.traits] = traits
        attributes[.family] = familyName

        let descriptor = StoryFontDescriptor(fontAttributes: attributes)

        // TODO: handle diff between macOS & iOS
        return StoryFont(descriptor: descriptor, size: pointSize) ?? StoryFont.getSystemFont(size: pointSize, weight: weight)
    }

    private static var fontsRegistered: Bool = false
    static func registerFontsIfNeeded() {
        guard !fontsRegistered else { return }
        guard let fontURLs = Bundle.module.urls(forResourcesWithExtension: "ttf", subdirectory: nil) else { return }
        let otfFontURLs = Bundle.module.urls(forResourcesWithExtension: "otf", subdirectory: nil)
        
        fontURLs.forEach({ CTFontManagerRegisterFontsForURL($0 as CFURL, .process, nil) })
        otfFontURLs?.forEach({ CTFontManagerRegisterFontsForURL($0 as CFURL, .process, nil) })
        
        fontsRegistered = true
    }
    
    static func regular(ofSize size: CGFloat, weight: StoryFont.Weight? = nil) -> StoryFont {
        getFont(name: "Inter-Regular", size: size, weight: weight)
    }
    static func semibold(ofSize size: CGFloat) -> StoryFont {
        getFont(name: "Inter-SemiBold", size: size)
    }
    static func bold(ofSize size: CGFloat) -> StoryFont {
        getFont(name: "Inter-Bold", size: size)
    }
    static func medium(ofSize size: CGFloat) -> StoryFont {
        getFont(name: "Inter-Medium", size: size)
    }
    
    static func regular(fontFamily: String, ofSize size: CGFloat, weight: StoryFont.Weight? = nil) -> StoryFont {
        getFont(name: fontFamily, size: size, weight: weight)
    }
    
    static func font(family: String, ofSize size: CGFloat, weight: StoryFont.Weight? = nil) -> StoryFont {
        return getFont(name: family, size: size, weight: weight)
    }
    
    // TODO: After all replace using of font method to improvedFont method
    static func improvedFont(family: String, ofSize size: CGFloat, weight: Double? = nil) -> StoryFont {
        let fontWeight: StoryFont.Weight
        if let weight = weight {
            switch weight {
            case 400:
                fontWeight = .regular
            case 500:
                fontWeight = .medium
            case 600:
                fontWeight = .semibold
            case 700:
                fontWeight = .bold
            default:
                fontWeight = .regular
            }
        } else {
            fontWeight = .regular
        }
        
        
        
        let points = sizeInPoints(size)
        return getFont(name: family, size: points, weight: fontWeight)
    }
    
    static func sizeInPoints(_ fontSize: Double) -> CGFloat {
        fontSize
    }
}
