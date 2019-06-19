//
//  OfficeButton.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/19/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import UIKit

class OfficeButton: BaseButton {
    let purchasedColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    let standardColor = #colorLiteral(red: 0.7511208653, green: 0.7511208653, blue: 0.7511208653, alpha: 1)
    let selectedColor = #colorLiteral(red: 0.2039215686, green: 0.7450980392, blue: 0.9647058824, alpha: 1)
    
    var purchased: Bool = false
    var isInUse: Bool = false {
        didSet {
            borderColor()
        }
    }
    
    override func sharedInit() {
        super.sharedInit()
        corners(value: frame.width / 2)
        borderColor(value: #colorLiteral(red: 0.7511208653, green: 0.7511208653, blue: 0.7511208653, alpha: 1))
        borderThickness(value: 5)
    }
    
    override func borderColor(value: UIColor? = nil) {
        super.borderColor(value: isInUse ? selectedColor : purchased ? purchasedColor : standardColor)
    }
}
