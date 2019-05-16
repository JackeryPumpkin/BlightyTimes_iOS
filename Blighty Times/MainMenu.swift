//
//  MainMenu.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/15/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import UIKit

class MainMenu: UIViewController {
    func newGame() {
        performSegue(withIdentifier: "newGameSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newGameSegue" {
            guard let controller = segue.destination as? GameViewController else { return }
            controller.delegate = self
        }
    }
}
