//
//  ImageCache.swift
//  
//
//  Created by Aleksei Cherepanov on 13.05.2022.
//

import UIKit

public protocol ImageCache: AnyObject {
    func loadImage(_ key: String) -> UIImage?
    func saveImage(_ key: String, image: UIImage)
    func removeImage(_ key: String)
    func removeAll()
}
