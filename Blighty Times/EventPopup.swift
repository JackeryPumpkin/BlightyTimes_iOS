//
//  EventPopup.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 7/9/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import UIKit

class EventPopup: Popup {
    private var eventImage: UIImageView!
    private var eventTitle: UILabel!
    private var eventDetail: UILabel!
    private var buttonStack: UIStackView!
    private var event: Event
    
    init(with event: Event) {
        self.event = event
        
        super.init()
        
        color = event.color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        eventImage = UIImageView()
        eventImage.image = event.image
        eventTitle = UILabel()
        eventTitle.text = event.title
        eventDetail = UILabel()
        eventDetail.text = event.message
        buttonStack = UIStackView()
        
        let okayButton: BaseButton = BaseButton()
        okayButton.setTitle("GOT IT", for: .normal)
        add(button: okayButton, action: #selector(close), target: self)
        
        event.hasBeenShown = true
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        applyConstraints()
        applyAesthetics()
    }
    
    func add(button: BaseButton, action: Selector, target: Any?) {
        button.addTarget(target, action: action, for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .black)
        button.color = event.color - 0.1
        buttonStack.addArrangedSubview(button)
    }
    
    private func applyAesthetics() {
        eventImage.roundCorners(withIntensity: .full)
        
        eventTitle.font = UIFont.systemFont(ofSize: 30, weight: .black)
        eventTitle.numberOfLines = 2
        eventTitle.textAlignment = .center
        eventTitle.adjustsFontSizeToFitWidth = false
        eventTitle.textColor = .black
        
        eventDetail.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        eventDetail.numberOfLines = 0
        eventDetail.textAlignment = .center
        eventDetail.adjustsFontSizeToFitWidth = true
        eventDetail.minimumScaleFactor = 0.5
        eventDetail.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8)
        
        buttonStack.backgroundColor = .black
    }
    
    private func applyConstraints() {
        eventImage.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(eventImage)
        eventImage.topAnchor.constraint(equalTo: card.topAnchor, constant: 50).isActive = true
        eventImage.widthAnchor.constraint(equalToConstant: 200).isActive = true
        eventImage.heightAnchor.constraint(equalToConstant: 200).isActive = true
        eventImage.centerXAnchor.constraint(equalTo: card.centerXAnchor).isActive = true
        
        eventTitle.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(eventTitle)
        eventTitle.topAnchor.constraint(equalTo: eventImage.bottomAnchor, constant: 30).isActive = true
        eventTitle.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 30).isActive = true
        eventTitle.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -30).isActive = true
        
        eventDetail.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(eventDetail)
        eventDetail.topAnchor.constraint(equalTo: eventTitle.bottomAnchor, constant: 14).isActive = true
        eventDetail.leftAnchor.constraint(equalTo: eventTitle.leftAnchor, constant: 0).isActive = true
        eventDetail.rightAnchor.constraint(equalTo: eventTitle.rightAnchor, constant: 0).isActive = true
        
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(buttonStack)
        buttonStack.topAnchor.constraint(greaterThanOrEqualTo: eventDetail.bottomAnchor, constant: 20).isActive = true
        buttonStack.leftAnchor.constraint(equalTo: eventTitle.leftAnchor, constant: 0).isActive = true
        buttonStack.rightAnchor.constraint(equalTo: eventTitle.rightAnchor, constant: 0).isActive = true
        buttonStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -30).isActive = true
        buttonStack.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        view.layoutIfNeeded()
    }
}
