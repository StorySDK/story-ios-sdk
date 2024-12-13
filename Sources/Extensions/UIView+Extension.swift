//
//  UIView+Extension.swift
//
//
//  Created by Ingvarr Alef on 13/12/2024.
//

import UIKit

extension UIView {
    
    func addTapTarget(_ target: Any, action: Selector) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: target, action: action)
        tap.numberOfTapsRequired = 1
        
        isUserInteractionEnabled = true
        addGestureRecognizer(tap)
    }
}
