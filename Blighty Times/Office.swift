//
//  Office.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/19/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import UIKit

class Office {
    var name: String
    var image: UIImage
    var capacity: Int
    var moraleModifier: Double
    var moraleModifierSymbol: String
    var regionCount: Int
    var dailyCosts: Int
    var downPayment: Int
    var purchased: Bool
    var size: OfficeSize
    
    init(size: OfficeSize) {
        switch size {
        case .small:
            name = "Small"
            capacity = 2
            moraleModifier = 0.9
            moraleModifierSymbol = "-"
            regionCount = 1
            image = #imageLiteral(resourceName: "office1")
        case .medium:
            name = "Medium"
            capacity = 4
            moraleModifier = 1.2
            moraleModifierSymbol = "+"
            regionCount = 2
            image = #imageLiteral(resourceName: "office2")
        case .large:
            name = "Large"
            capacity = 6
            moraleModifier = 1.6
            moraleModifierSymbol = "++"
            regionCount = 3
            image = #imageLiteral(resourceName: "office3")
        case .huge:
            name = "Huge"
            capacity = 10
            moraleModifier = 2.0
            moraleModifierSymbol = "++++"
            regionCount = 4
            image = #imageLiteral(resourceName: "office4")
        }
        
        downPayment = 10000 * (size.rawValue * 2)
        dailyCosts = 500 * Int(pow(Float(size.rawValue + 1), 3))
        purchased = false
        self.size = size
    }
    
    static func small() -> Office {
        return Office(size: .small)
    }
    
    static func medium() -> Office {
        return Office(size: .medium)
    }
    
    static func large() -> Office {
        return Office(size: .large)
    }
    
    static func huge() -> Office {
        return Office(size: .huge)
    }
}

enum OfficeSize: Int, CaseIterable {
    case small = 0
    case medium = 1
    case large = 2
    case huge = 3
}
