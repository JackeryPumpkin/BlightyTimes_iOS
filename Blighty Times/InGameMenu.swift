//
//  InGameMenu.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/13/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import UIKit

class InGameMenu: UIViewController {
    var delegate: GameViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func restart(_ sender: Any) {
        dismiss(animated: true) {
            guard let game = self.delegate else { return }
            game.dismiss(animated: false, completion: {
                guard let mainMenu = game.delegate else { return }
                mainMenu.newGame()
            })
        }
    }
    
    @IBAction func mainMenu(_ sender: Any) {
        dismiss(animated: true) {
            if let delegate = self.delegate {
                delegate.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func back(_ sender: Any) {
        
        dismiss(animated: true) {
            if let delegate = self.delegate {
                delegate.stateMachine.toLastState()
            }
        }
    }
}
