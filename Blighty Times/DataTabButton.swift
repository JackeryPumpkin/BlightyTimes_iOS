//
//  DataTabButton.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/19/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import UIKit

class DataTabButton: BaseButton {
    override open var isHighlighted: Bool {
        didSet {
            titleLabel?.alpha = 1
        }
    }
    
    override open var isEnabled: Bool {
        didSet {
            
        }
    }
    
    var isInUse: Bool = false {
        didSet {
            if isInUse {
                setTitleColor(#colorLiteral(red: 0.3921568627, green: 0.3921568627, blue: 0.3921568627, alpha: 1), for: .normal)
            } else {
                setTitleColor(#colorLiteral(red: 0.3921568627, green: 0.3921568627, blue: 0.3921568627, alpha: 0.6), for: .normal)
            }
        }
    }
    
    override func sharedInit() {
        super.sharedInit()
        setTitleColor(#colorLiteral(red: 0.3921568627, green: 0.3921568627, blue: 0.3921568627, alpha: 1), for: .normal)
        setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .highlighted)
        setTitleColor(#colorLiteral(red: 0.3921568627, green: 0.3921568627, blue: 0.3921568627, alpha: 0.6), for: .disabled)
        
        titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
}
