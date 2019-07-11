//
//  Popup.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 7/4/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import UIKit

class Popup: UIViewController {
    private var fullscreen: UIView!
    private var cardButton: UIButton!
    private var cardX: NSLayoutConstraint = NSLayoutConstraint()
    private var cardY: NSLayoutConstraint = NSLayoutConstraint()
    var card: UIView!
    var color: UIColor { didSet { cardButton.backgroundColor = color } }
    
    init() {
        cardButton = UIButton()
        color = .white
        
        super.init(nibName: nil, bundle: nil)
        
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.isOpaque = false
        view.backgroundColor = .clear
        
        // Set up the container which is the background for the event popup
        fullscreen = UIView(frame: view.frame)
        fullscreen.translatesAutoresizingMaskIntoConstraints = false
        fullscreen.backgroundColor = #colorLiteral(red: 0.262745098, green: 0.262745098, blue: 0.3137254902, alpha: 0.5028360445)
        view.addSubview(fullscreen)
        
        // Set up the cardButton which acts as the shadow and touch responder for the card
        cardButton.translatesAutoresizingMaskIntoConstraints = false
        fullscreen.addSubview(cardButton)
        cardButton.roundCorners(withIntensity: .heavy)
        cardButton.addShadow(radius: 8, height: 10, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4))
        cardButton.backgroundColor = color
        
        // Set up the card which contains the popup's images, text and buttons
        card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        fullscreen.addSubview(card)
        card.roundCorners(withIntensity: .heavy)
        card.backgroundColor =  .clear
        card.isUserInteractionEnabled = false
        
        cardX = cardButton.centerXAnchor.constraint(equalTo: fullscreen.centerXAnchor)
        cardY = cardButton.centerYAnchor.constraint(equalTo: fullscreen.centerYAnchor, constant: (view.frame.height / 2) + (fullscreen.frame.height / 2))
        
        NSLayoutConstraint.activate([
            fullscreen.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            fullscreen.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            fullscreen.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            fullscreen.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            
            cardButton.widthAnchor.constraint(equalToConstant: 400),
            cardButton.heightAnchor.constraint(equalToConstant: 550),
            
            card.topAnchor.constraint(equalTo: cardButton.topAnchor, constant: 0),
            card.leftAnchor.constraint(equalTo: cardButton.leftAnchor, constant: 0),
            card.bottomAnchor.constraint(equalTo: cardButton.bottomAnchor, constant: 0),
            card.rightAnchor.constraint(equalTo: cardButton.rightAnchor, constant: 0),
            
            cardX, cardY
        ])
        
        view.layoutIfNeeded()
        
        cardButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        cardY.isActive = false
        cardY = cardButton.centerYAnchor.constraint(equalTo: fullscreen.centerYAnchor)
        cardY.isActive = true
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func close() {
        let X: CGFloat = (view.frame.width / 2) + (fullscreen.frame.width / 2)
        let Y: CGFloat = (view.frame.height / 2) + (fullscreen.frame.height / 2)
        
        cardX.isActive = false
        cardY.isActive = false
        
        // This set the exit trajectory to a random-ish vector
        var rand = Int.random(in: -10 ... 10)
        cardX = cardButton.centerXAnchor.constraint(equalTo: fullscreen.centerXAnchor, constant: X * CGFloat(rand))
        rand = Int.random(in: -10 ... 10)
        cardY = cardButton.centerYAnchor.constraint(equalTo: fullscreen.centerYAnchor, constant: Y * CGFloat(rand))
        
        cardX.isActive = true
        cardY.isActive = true
        
        UIView.animate(withDuration: 1, animations: {
            self.view.layoutIfNeeded()
        }) { success in
            self.dismiss(animated: true, completion: nil)
        }
    }
}
