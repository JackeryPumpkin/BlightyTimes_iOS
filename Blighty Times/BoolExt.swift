//
//  BoolExt.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 7/4/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import Foundation

extension Bool {
    static func coinFlip() -> Bool {
        return Int.random(in: 0 ... 1) == 1
    }
}
