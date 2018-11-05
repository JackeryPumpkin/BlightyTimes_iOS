//
//  Event.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 11/4/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import UIKit

class Event {
    let message: String;
    let color: UIColor;
    let symbol: String;
    var lifetime: Int;
    
    init(message: String, type: EventType) {
        self.message = message;
        
        switch type {
        case .news:
            color = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1);
            symbol = "🗞";
            lifetime = Simulation.TICKS_PER_DAY;
        case .employee:
            color = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1);
            symbol = "👤";
            lifetime = Simulation.TICKS_PER_DAY / 4;
        case .applicant:
            color = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1);
            symbol = "🗣";
            lifetime = Simulation.TICKS_PER_DAY / 5;
        case .company:
            color = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1);
            symbol = "🏛";
            lifetime = Simulation.TICKS_PER_DAY / 4;
        case .readership:
            color = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1);
            symbol = "👓";
            lifetime = Simulation.TICKS_PER_DAY / 3;
        }
    }
    
    func tick() {
        lifetime -= lifetime > 0 ? 1 : 0;
    }
}

enum EventType {
    case news;
    case employee;
    case applicant;
    case company;
    case readership;
}
