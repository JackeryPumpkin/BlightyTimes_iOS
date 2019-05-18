//
//  UIColorExt.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/18/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import UIKit

extension UIColor {
    ///Returns a lighter color
    static func +(color: UIColor, modification: Double) -> UIColor {
        if let components = color.cgColor.components {
            var red: CGFloat = 0
            var blue: CGFloat = 0
            var green: CGFloat = 0
            
            for i in 0 ..< components.count {
                if i == 0 {
                    red = components[i]
                } else if i == 1 {
                    green = components[i]
                } else if i == 2 {
                    blue = components[i]
                }
            }
            
            return UIColor(red: red + CGFloat(modification),
                           green: green + CGFloat(modification),
                           blue: blue + CGFloat(modification),
                           alpha: color.cgColor.alpha)
        } else {
            return color
        }
    }
    
    ///Returns a darker color
    static func -(color: UIColor, modification: Double) -> UIColor {
        return color + -modification
    }
    
    ///The color on the left side of the equals sign will be made lighter
    static func +=(color: inout UIColor, modification: Double) {
        color = color + modification
    }
    
    ///The color on the left side of the equals sign will be made darker
    static func -=(color: inout UIColor, modification: Double) {
        color = color - modification
    }
    
    ///Returns true if the left side of the comparison is lighter
    static func >(left: UIColor, right: UIColor) -> Bool {
        guard let lComponents = left.cgColor.components else { return false }
        guard let rComponents = right.cgColor.components else { return false }
        
        var lTotal: CGFloat = 0
        var rTotal: CGFloat = 0
        
        for i in 0 ..< lComponents.count {
            if i != lComponents.count - 1 {
                lTotal += lComponents[i]
            }
        }
        
        for i in 0 ..< rComponents.count {
            if i != rComponents.count - 1 {
                rTotal += rComponents[i]
            }
        }
        
        return lTotal > rTotal
    }
    
    ///Returns true if the left side of the comparison is darker
    static func <(left: UIColor, right: UIColor) -> Bool {
        return !(left > right)
    }
    
    
    ///Returns true if the both sides of the comparison are the same color
    static func ==(left: UIColor, right: UIColor) -> Bool {
        guard let lComponents = left.cgColor.components else { return false }
        guard let rComponents = right.cgColor.components else { return false }
        
        var lTotal: CGFloat = 0
        var rTotal: CGFloat = 0
        
        for i in 0 ..< lComponents.count {
            if i != lComponents.count - 1 {
                lTotal += lComponents[i]
            }
        }
        
        for i in 0 ..< rComponents.count {
            if i != rComponents.count - 1 {
                rTotal += rComponents[i]
            }
        }
        
        return lTotal == rTotal
    }
    
    //
    //Objective-C method variants
    //
    ///Returns a lighter version of self's color by a given amount
    @objc func dodge(amount: Double) -> UIColor {
        return self + amount
    }
    
    ///Returns a darker version of self's color by a given amount
    @objc func burn(amount: Double) -> UIColor {
        return self - amount
    }
    
    ///Returns true if self is darker than the method argument
    @objc func isDarkerThanColor(_ color: UIColor) -> Bool {
        return self < color
    }
    
    ///Returns true if self is lighter than the method argument
    @objc func isLighterThanColor(_ color: UIColor) -> Bool {
        return self > color
    }
    
    ///Returns true if self is the same color as the method argument
    @objc func isSameColorAs(_ color: UIColor) -> Bool {
        return self == color
    }
}
