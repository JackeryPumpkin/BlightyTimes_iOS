//
//  MenuButton.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/18/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import UIKit

class RedButton: BaseButton {
    override func sharedInit() {
        super.sharedInit()
        setTitleColor(.white, for: .normal)
        setTitleColor(.white, for: .highlighted)
        setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6), for: .disabled)
    }
    
    override func corners(value: CGFloat) {
        super.corners(value: 0)
        color = #colorLiteral(red: 0.8795482516, green: 0.1792428792, blue: 0.3018780947, alpha: 1)
    }
}
