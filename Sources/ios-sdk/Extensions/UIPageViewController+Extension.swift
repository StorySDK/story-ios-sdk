//
//  UIView+Extension.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 18.02.2022.
//

import UIKit

extension UIPageViewController {
    var isPagingEnabled: Bool {
        get {
            return scrollView?.isScrollEnabled ?? false
        }
        set {
            scrollView?.isScrollEnabled = newValue
        }
    }

    var scrollView: UIScrollView? {
        return view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
    }
}
