//
//  InGameButton.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/19/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import UIKit

class InGameButton: RedButton {
    override func sharedInit() {
        super.sharedInit()
        titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .black)
    }
}
