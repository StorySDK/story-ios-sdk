//
//  UIImageView+Extensions.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

#if os(iOS)
import UIKit

extension UIImageView {
    public func load(url: URL, completion: (() -> Void)? = nil) {
        DispatchQueue.global().async { [weak self] in
            guard let data = try? Data(contentsOf: url) else { return }
            guard let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.image = image
                completion?()
            }
        }
    }
}
#endif
