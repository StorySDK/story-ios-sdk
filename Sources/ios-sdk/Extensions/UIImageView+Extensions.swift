//
//  UIImageView+Extensions.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

#if os(iOS)
import UIKit

extension UIImageView {
    public func load(url: URL, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                        completion?()
                    }
                }
            }
        }
    }
}
#endif
