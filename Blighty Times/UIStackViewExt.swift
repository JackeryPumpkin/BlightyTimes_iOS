//
//  UIStackViewExt.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 6/7/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import UIKit

extension UIStackView {
    func removeFirstArrangedSubview() {
        if let item = arrangedSubviews.first {
            removeArrangedSubview(item)
            item.removeFromSuperview()
        }
    }
    
    func removeLastArrangedSubview() {
        if let item = arrangedSubviews.last {
            removeArrangedSubview(item)
            item.removeFromSuperview()
        }
    }
    
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}
