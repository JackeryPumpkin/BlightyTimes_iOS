//
//  UIViewExt.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/18/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import UIKit

extension UIView {
    func addShadow(radius: CGFloat, height: CGFloat, color: UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)) {
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = radius
        self.layer.shadowOffset = CGSize(width: 0.0, height: height)
        self.layer.shadowColor = color.cgColor;
    }
    
    func addBorders(width: CGFloat, color: CGColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color
    }
    
    func roundCorners(withIntensity level: Roundness) {
        self.clipsToBounds = true;
        
        switch level {
        case .slight:
            self.layer.cornerRadius = 5.0
        case .heavy:
            self.layer.cornerRadius = 15.0
        case .full:
            self.layer.cornerRadius = self.frame.width > self.frame.height ? self.frame.height / 2 : self.frame.width / 2
        }
    }
    
    func show() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1
        })
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        })
    }
    
    enum Roundness {
        case slight
        case heavy
        case full
    }
}