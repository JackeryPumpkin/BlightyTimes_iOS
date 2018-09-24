//
//  EmployedAuthorCell.swift
//  BlightyTimes
//
//  Created by Zachary Duncan on 8/27/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import UIKit

class EmployedAuthorCell: UITableViewCell {
    @IBOutlet weak var authorPortrait: UIImageView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var authorTitle: UILabel!
    @IBOutlet weak var authorBonus: UILabel!
    @IBOutlet weak var authorProgress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        authorPortrait.layer.cornerRadius = authorPortrait.frame.width / 2;
        authorPortrait.clipsToBounds = true;
    }
}

