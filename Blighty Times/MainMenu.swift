//
//  MainMenu.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/15/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import UIKit

class MainMenu: UIViewController {
    var gameMode: GameMode?
    
    override func viewDidAppear(_ animated: Bool) {
        let event = Event(title: "Test", message: "Fancy message to display", color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), image: #imageLiteral(resourceName: "RichardFeak"), lifetime: 0)
        present(EventPopup(with: event), animated: true, completion: nil)
    }
    
    func newGame() {
        performSegue(withIdentifier: "newGameSegue", sender: nil)
    }
    
    @IBAction func randomStart(_ sender: Any) {
        gameMode = .random
        newGame()
    }
    
    @IBAction func smallStart(_ sender: Any) {
        gameMode = .small
        newGame()
    }
    
    @IBAction func mediumStart(_ sender: Any) {
        gameMode = .medium
        newGame()
    }
    
    @IBAction func largeStart(_ sender: Any) {
        gameMode = .large
        newGame()
    }
    
    @IBAction func hugeStart(_ sender: Any) {
        gameMode = .huge
        newGame()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newGameSegue" {
            guard let controller = segue.destination as? GameViewController else { return }
            guard let gameMode = gameMode else { return }
            
            controller.delegate = self
            controller.sim.gameMode = gameMode
        }
    }
}

enum GameMode {
    case small
    case medium
    case large
    case huge
    case random
    case story
}
