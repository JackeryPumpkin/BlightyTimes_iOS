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
    var purchased: Bool
    
    init(name: String, capacity: Int, moraleModifier: Double, regionCount: Int, dailyCosts: Int, image: UIImage) {
        self.name = name
        self.capacity = capacity
        self.moraleModifier = moraleModifier
        self.regionCount = regionCount
        self.dailyCosts = dailyCosts
        self.image = image
        purchased = false
        
        if name == "Small" { moraleModifierSymbol = "-" }
        else if name == "Medium" { moraleModifierSymbol = "+" }
        else if name == "Large" { moraleModifierSymbol = "++" }
        else if name == "Huge" { moraleModifierSymbol = "++++" }
        else { moraleModifierSymbol = "?" }
    }
    
    static func small() -> Office {
        return Office(name: "Small", capacity: 2, moraleModifier: 0.9, regionCount: 2, dailyCosts: 500, image: #imageLiteral(resourceName: "office1"))
    }
    
    static func medium() -> Office {
        return Office(name: "Medium", capacity: 4, moraleModifier: 1.2, regionCount: 3, dailyCosts: 2000, image: #imageLiteral(resourceName: "office2"))
    }
    
    static func large() -> Office {
        return Office(name: "Large", capacity: 6, moraleModifier: 1.6, regionCount: 4, dailyCosts: 5000, image: #imageLiteral(resourceName: "office3"))
    }
    
    static func huge() -> Office {
        return Office(name: "Huge", capacity: 10, moraleModifier: 2.0, regionCount: 4, dailyCosts: 20000, image: #imageLiteral(resourceName: "office4"))
    }
}

enum OfficeSize: Int {
    case small = 0
    case medium = 1
    case large = 2
    case huge = 3
}
