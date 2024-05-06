//
//  SRLoader.swift
//  StorySDK
//
//  Created by Ingvarr Alef on 03/05/2024.
//

import UIKit

public protocol SRLoadingIndicator: AnyObject {
    func startAnimating()
    func stopAnimating()
}

public protocol SRLoader: SRLoadingIndicator where Self: UIView {}
