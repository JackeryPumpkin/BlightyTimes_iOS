//
//  EventController.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 6/16/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import UIKit

class EventController: UIViewController {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var containerShadow: UIButton!
    @IBOutlet weak var containerCenterY: NSLayoutConstraint!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDetail: UILabel!
    @IBOutlet weak var okayButton: BaseButton!
    @IBOutlet weak var cancelButton: BaseButton!
    
    var event: Event?
    
    override func viewDidLoad() {
        guard let event = event else { dismiss(animated: true, completion: nil); return }
        
        containerShadow.roundCorners(withIntensity: .heavy)
        containerShadow.addShadow(radius: 8, height: 10, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4))
        containerShadow.backgroundColor = event.color + 0.2
        
        eventImage.image = event.image
        eventTitle.text = event.title
        eventDetail.text = event.message
        cancelButton.isHidden = !(event is FiringEvent)
        okayButton.color = event.color - 0.1
        cancelButton.color = event.color - 0.1
        
        if !(event is NewsEvent) {
            //Rounds image when it's an author's portrait
            eventImage.roundCorners(withIntensity: .full)
        }
        
        if event is FiringEvent {
            okayButton.setTitle("FIRE", for: .normal)
        }
        
        containerCenterY.constant = (view.frame.height / 2) + (container.frame.height / 2)
        view.layoutIfNeeded()
        
        event.hasBeenShown = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        containerCenterY.constant = 0
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func okay(_ sender: Any) {
        containerCenterY.constant = (view.frame.height / 2) + (container.frame.height / 2)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        }) { (complete) in
            self.dismiss(animated: true) {
                if let action = self.event?.okayAction {
                    action()
                }
            }
        }
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        containerCenterY.constant = (view.frame.height / 2) + (container.frame.height / 2)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        }) { (complete) in
            self.dismiss(animated: true, completion: nil)
        }
    }
}

