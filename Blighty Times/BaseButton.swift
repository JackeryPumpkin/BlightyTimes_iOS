//
//  MenuButton.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/18/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import UIKit

@IBDesignable class BaseButton: UIButton {
    @IBInspectable var color: UIColor = .clear {
        didSet {
            backgroundColor = color
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            corners(value: cornerRadius)
        }
    }
    
    @IBInspectable var borderThickness: CGFloat = 0 {
        didSet {
            borderThickness(value: borderThickness)
        }
    }
    
    @IBInspectable var borderColor: UIColor = #colorLiteral(red: 0.2039215686, green: 0.4745098039, blue: 0.9647058824, alpha: 1) {
        didSet {
            borderColor(value: borderColor)
        }
    }
    
    override open var isHighlighted: Bool {
        didSet {
            if backgroundColor != nil {
                if isHighlighted {
                    backgroundColor! = color - 0.15
                    layoutIfNeeded()
                } else {
                    backgroundColor! = color
                }
            }
            
            titleLabel?.alpha = 1
        }
    }
    
    override open var isEnabled: Bool {
        didSet {
            if isEnabled {
                alpha = 1
            } else {
                alpha = 0.9
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func sharedInit() {
        corners(value: cornerRadius)
        clipsToBounds = true
    }
    
    func corners(value: CGFloat) {
        layer.cornerRadius = value
    }
    
    func borderThickness(value: CGFloat) {
        layer.borderWidth = value
    }
    
    func borderColor(value: UIColor) {
        layer.borderColor = value.cgColor
    }
    
//    func addShadow(alpha: CGFloat, radius: CGFloat, height: CGFloat) {
//        self.layer.shadowOpacity = 1
//        self.layer.shadowRadius = radius
//        self.layer.shadowOffset = CGSize(width: 0.0, height: height)
//        self.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: alpha).cgColor
//    }
}
