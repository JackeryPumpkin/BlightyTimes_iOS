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
    @IBOutlet weak var experience: UILabel!
    
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var fireButton: UIButton!
    
    var toggleOverlay : (() -> Void)? = nil;
    var fire : (() -> Void)? = nil;
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        authorPortrait.roundCorners(withIntensity: .full);
    }
    
    func getProgressLength(_ progress: Double) -> CGFloat {
        if progress == 0 {
            return CGFloat(0);
        } else {
            return progressMaxConstraint.constant * CGFloat(progress / Double(Simulation.TICKS_PER_DAY));
        }
    }
    
    @IBAction func toggleOverlay(_ sender: Any) {
        if let action = self.toggleOverlay {
            action();
        }
    }
    
    func hideOverlay() {
        overlayView.isHidden = true;
        fireButton.isHidden = true;
    }
    
    @IBAction func fire(_ sender: Any) {
        if let action = self.fire {
            action();
        }
    }
}

