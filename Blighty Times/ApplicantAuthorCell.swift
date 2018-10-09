//
//  ApplicantAuthorCell.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 10/8/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import UIKit

class ApplicantAuthorCell: UITableViewCell {
    @IBOutlet weak var authorPortrait: UIImageView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var topicList: UILabel!
    @IBOutlet weak var quality: UILabel!
    @IBOutlet weak var speed: UILabel!
    @IBOutlet weak var salary: UILabel!
    
    var onButtonTapped : (() -> Void)? = nil;
    var wasTapped: Bool = false;
    
    override func awakeFromNib() {
        super.awakeFromNib();
        authorPortrait.roundCorners(withIntensity: .full);
    }
    
    @IBAction func hire(sender: UIButton) {
        if let onButtonTapped = self.onButtonTapped {
            onButtonTapped();
        }
    }
}
