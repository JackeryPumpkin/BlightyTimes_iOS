//
//  IntExt.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/20/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import Foundation

extension Int {
    func commaFormat() -> String {
        let numberFormatter = NumberFormatter();
        numberFormatter.numberStyle = NumberFormatter.Style.decimal;
        
        return numberFormatter.string(from: NSNumber(value: self))!;
    }
    
    func dollarFormat() -> String {
        let numberFormatter = NumberFormatter();
        numberFormatter.numberStyle = NumberFormatter.Style.decimal;
        if self >= 0 {
            return "$" + numberFormatter.string(from: NSNumber(value: self))!;
        } else {
            return "-$" + numberFormatter.string(from: NSNumber(value: self * -1))!;
        }
    }
    
    static func *(left: inout Int, right: Double) {
        left = Int(Double(left) * right)
    }
    
    static func /(left: inout Int, right: Double) {
        left = Int(Double(left) / right)
    }
    static func /(left: Int, right: Double) -> Int {
        return Int(Double(left) / right)
    }
}
