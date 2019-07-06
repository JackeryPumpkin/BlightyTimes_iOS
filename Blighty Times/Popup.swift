//
//  Popup.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 7/4/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import UIKit

class Popup: UIViewController {
    private var container: UIView!
    private var cardButton: UIButton!
    private var cardX: NSLayoutConstraint = NSLayoutConstraint()
    private var cardY: NSLayoutConstraint = NSLayoutConstraint()
    var card: UIView!
    var event: Event?
    
    override func viewDidLoad() {
        // Set up the container which is the background for the event popup
        container = UIView(frame: view.frame)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = #colorLiteral(red: 0.262745098, green: 0.262745098, blue: 0.3137254902, alpha: 1)
        
        //Set up the cardButton which acts as the shadow and touch responder for the card
        cardButton = UIButton()
        cardButton.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(cardButton)
        cardButton.roundCorners(withIntensity: .heavy)
        cardButton.addShadow(radius: 8, height: 10, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4))
        cardButton.backgroundColor = .blue
        
        //Set up the card which contains the popup's images, text and buttons
        card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(card)
        card.roundCorners(withIntensity: .heavy)
        card.backgroundColor = .yellow
        
        cardX = cardButton.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        cardY = cardButton.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: (view.frame.height / 2) + (container.frame.height / 2))
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            container.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            container.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            
            cardButton.widthAnchor.constraint(equalToConstant: 400),
            cardButton.heightAnchor.constraint(equalToConstant: 550),
            
            card.topAnchor.constraint(equalTo: cardButton.topAnchor, constant: 0),
            card.leftAnchor.constraint(equalTo: cardButton.leftAnchor, constant: 0),
            card.bottomAnchor.constraint(equalTo: cardButton.bottomAnchor, constant: 0),
            card.rightAnchor.constraint(equalTo: cardButton.rightAnchor, constant: 0),
            
            cardX, cardY
        ])
        
        view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        cardY.isActive = false
        cardY = cardButton.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        cardY.isActive = true
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func close() {
        let X = (view.frame.width / 2) + (container.frame.width / 2)
        let Y = (view.frame.height / 2) + (container.frame.height / 2)
        
        cardX.isActive = false
        cardY.isActive = false
        
        var rand = Int.random(in: -5 ... 5)
        cardX = cardButton.centerXAnchor.constraint(equalTo: container.centerXAnchor, constant: X * CGFloat(rand))
        rand = Int.random(in: -5 ... 5)
        cardY = cardButton.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: Y * CGFloat(rand))
        
        cardX.isActive = true
        cardY.isActive = true
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        }) { (complete) in
            self.dismiss(animated: true, completion: nil)
        }
    }
}
