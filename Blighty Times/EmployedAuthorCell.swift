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
    @IBOutlet weak var overlayButton: UIButton!
    @IBOutlet weak var fireButton: UIButton!
    @IBOutlet weak var qualityButton: UIButton!
    @IBOutlet weak var speedButton: UIButton!
    @IBOutlet weak var skillPoints: UILabel!
    
    var toggleOverlay : (() -> Void)? = nil;
    var fire : (() -> Void)? = nil;
    var promoteQuality : (() -> Void)? = nil;
    var promoteSpeed : (() -> Void)? = nil;
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        authorPortrait.roundCorners(withIntensity: .full);
        qualityButton.setTitleColor(.white, for: .normal);
        qualityButton.setTitleColor(#colorLiteral(red: 0.6198541522, green: 0.7646024823, blue: 0.9832029939, alpha: 1), for: .disabled);
        speedButton.setTitleColor(.white, for: .normal);
        speedButton.setTitleColor(#colorLiteral(red: 0.6198541522, green: 0.7646024823, blue: 0.9832029939, alpha: 1), for: .disabled);
    }
    
    func getProgressLength(_ progress: Double) -> CGFloat {
        if progress == 0 {
            return CGFloat(0);
        } else {
            return progressMaxConstraint.constant * CGFloat(progress / Double(Simulation.TICKS_PER_DAY));
        }
    }
    
    @IBAction func toggleOverlay(_ sender: Any) {
        if overlayView.isHidden {
            showOverlay();
        } else {
            hideOverlay();
        }
        
        if let action = self.toggleOverlay {
            action();
        }
    }
    
    func hideOverlay() {
        overlayView.isHidden = true;
        self.backgroundColor = .white;
        overlayButton.setTitle("⚙︎", for: .normal);
        overlayButton.setValue(1.0, forKeyPath: "alpha")
    }
    
    func showOverlay() {
        overlayView.isHidden = false;
        self.backgroundColor = #colorLiteral(red: 0.9276894927, green: 0.9221747518, blue: 0.9319286346, alpha: 1);
        overlayButton.setTitle("✗", for: .normal);
        overlayButton.setValue(0.6, forKeyPath: "alpha")
        showSkillButtons();
    }
    
    func showSkillButtons() {
        if skillPoints.text != "0" {
            qualityButton.isEnabled = true;
            speedButton.isEnabled = true;
        } else {
            qualityButton.isEnabled = false;
            speedButton.isEnabled = false;
        }
    }
    
    @IBAction func fire(_ sender: Any) {
        if let action = self.fire {
            action();
        }
    }
    @IBAction func qualityButton(_ sender: Any) {
        if let action = self.promoteQuality {
            action();
        }
    }
    
    @IBAction func speedButton(_ sender: Any) {
        if let action = self.promoteSpeed {
            action();
        }
    }
}

