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
    @IBOutlet weak var level: UILabel!
    @IBOutlet weak var topicList: UILabel!
    @IBOutlet weak var publications: UILabel!
    @IBOutlet weak var salary: UILabel!
    @IBOutlet weak var speed: UILabel!
    @IBOutlet weak var morale: UILabel!
    @IBOutlet weak var progressConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressMaxConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        authorPortrait.layer.cornerRadius = authorPortrait.frame.width / 2;
        authorPortrait.clipsToBounds = true;
    }
    
    func getProgressLength(_ progress: Double) -> CGFloat {
        if progress == 0 {
            return CGFloat(0);
        } else {
            return progressMaxConstraint.constant * CGFloat(progress / 100);
        }
    }
}

