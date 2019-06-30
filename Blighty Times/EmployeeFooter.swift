//
//  EmployeeFooter.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 6/28/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import UIKit

class EmployeeFooter: UIView {
    @IBOutlet weak var authors: UILabel!
    
    func author(count: Int, capacity: Int) {
        authors.text = "\(count) / \(capacity)"
    }
}
