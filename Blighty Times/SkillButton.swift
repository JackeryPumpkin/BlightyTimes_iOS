//
//  SkillButton.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/18/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import UIKit

class SkillButton: RedButton {
    override func sharedInit() {
        super.sharedInit()
        color = #colorLiteral(red: 0.2039215686, green: 0.4745098039, blue: 0.9647058824, alpha: 1)
        titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .black)
    }
}
