//
//  Company.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 9/24/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import Foundation

class Company {
    private var _funds: Int = 500000;
    private var _expensesDaily: Int = 156;
    
    private var _subscribers: Int = 0;
    private var _newSubscribers: Int = 0;
    
    private var _experience: Int = 0;
    private var _experienceGained: Int = 0;
    private var _level: Int = 0;
    
    
    //Company tick happens once a day
    func tick() {
        _newSubscribers = 0;
    }
    
    func giveExperience(from newSubscribers: Int) {
        _experienceGained = 0;
        
        if _newSubscribers < 20 {
            _experience += 10;
            _experienceGained += 10;
        } else if _newSubscribers < 100 {
            _experience += 50;
            _experienceGained += 50;
        } else if _newSubscribers < 200 {
            _experience += 150;
            _experienceGained += 150;
        }
        
        _experience += _experienceGained;
    }
    
    func getExperience() -> Int {
        return _experience;
    }
    
    func getExperienceGained() -> Int {
        return _experienceGained;
    }
    
    func hiredEmployee() {
        _experience += 20;
        _experienceGained += 20;
    }
}
