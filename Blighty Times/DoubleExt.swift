//
//  DoubleExt.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 6/10/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import Foundation

extension Double {
    func hundredthFormat() -> String {
        let numberFormatter = NumberFormatter();
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = 2
        
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}
