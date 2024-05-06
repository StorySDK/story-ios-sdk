//
//  ImageCache.swift
//  
//
//  Created by Aleksei Cherepanov on 13.05.2022.
//

#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

protocol ImageCache: AnyObject {
    func hasImage(_ key: String) -> Bool
    func loadImage(_ key: String) -> StoryImage?
    func saveImage(_ key: String, image: StoryImage)
    func removeImage(_ key: String)
    func removeAll()
}
