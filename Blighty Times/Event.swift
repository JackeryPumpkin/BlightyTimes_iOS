//
//  Event.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 11/4/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import UIKit

class Event {
    var message: String;
    let color: UIColor;
    let symbol: String;
    var lifetime: Int;
    
    init(message: String, color: UIColor, symbol: String, lifetime: Int) {
        self.message = message;
        self.color = color;
        self.symbol = symbol;
        self.lifetime = lifetime;
    }
    
    final func tick() {
        lifetime -= lifetime > 0 ? 1 : 0;
    }
}


class NewsEvent: Event {
    private let _NEWS_TOPIC: Topic;
    
    init() {
        _NEWS_TOPIC = TopicLibrary.getRandomTopics()[0];
        super.init(message: "", color: _NEWS_TOPIC.getColor(), symbol: "📰", lifetime: 0);
        
        message = message();
        lifetime = lifetime();
    }
    
    func getTopic() -> Topic {
        return _NEWS_TOPIC;
    }
    
    final private func message() -> String {
        switch _NEWS_TOPIC.getName() {
        case "Conservatism":
            let options: [String] = [
                "Conservative politition embroiled in intense scandal.",
                "Conservative politition being celebrated for recent accomplishment."
            ]
            
            return options[Random(index: options.count)];
            
        case "Liberalism":
            let options: [String] = [
                "Liberal politition embroiled in intense scandal.",
                "Liberal politition being celebrated for recent accomplishment."
            ]
            
            return options[Random(index: options.count)];
            
        case "Children":
            let options: [String] = [
                "Nuclear \"incident\" near primary school.",
                "Blighty citizens are being harassed by an growing gang of children.",
                "Child prodigy starts at new position at NASA.",
                "Child prodigy plays violin with Tim Minchin in front of 10,000 people."
            ]
            
            return options[Random(index: options.count)];
            
        case "Violence":
            let options: [String] = [
                "Chuck Norris just gave an NRA talk at a local park.",
                "Martial arts classes are half off city-wide.",
                "Theft is becoming more and more common in Central Blighty.",
                "Crime is on the rise.",
                "UFC Match to be hosted in Blighty Square Garden.",
                "Everyone is talking about a viral video of two geese fighting over bread."
            ]
            
            return options[Random(index: options.count)];
            
        case "Education":
            let options: [String] = [
                "Standardized test scores are at an all-time low.",
                "Graduation rate is an all-time high at local schools."
            ]
            
            return options[Random(index: options.count)];
            
        case "Theatre":
            let options: [String] = [
                "Local theatre shutters its door front lack of attendance.",
                "New satirical musical is a masterpiece, breaking sales records."
            ]
            
            return options[Random(index: options.count)];
            
        case "Travel":
            let options: [String] = [
                "The mayor of Blighty has put a travel ban on all flights to Babylon.",
                "A wild fire has sprung up preventing commuters traveling to the west.",
                "An upscale resort in the Caribbean is 50% off to all Blighty residents.",
                "Blighty's Got Talent is filming its finale in Springfield next week."
            ]
            
            return options[Random(index: options.count)];
            
        case "Sports":
            let options: [String] = [
                "Blighty City Stadium will be hosting an American \"football\" game today.",
                "Blighty won 2 medals at the Olympics and they were bronze.",
                "Tickets to the West Blight vs Blighty United game have sold out.",
                "Another day goes by and still no one cares about fencing.",
                "Longest cricket match in Blighty history continues into its fifth day."
            ]
            
            return options[Random(index: options.count)];
            
        case "Film":
            let options: [String] = [
                "Stephen Fry is premiering a documentary on ravens and writing desks.",
                "New film by Quentin Tarantino is sparking an intense dialogue among viewers.",
                "Fawlty Towers is being made into a Hollywood film staring Tom Cruise.",
                "Lock, Stock and Three Smoking Barrels script details were leaked online."
            ]
            
            return options[Random(index: options.count)];
            
        case "Science":
            let options: [String] = [
                "Elon Musk showed a personal size rocket car that's powered by time.",
                "Richard Dawkins to give three live zoology presentations for kids."
            ]
            
            return options[Random(index: options.count)];
            
        case "Religion":
            let options: [String] = [
                "Religious conflict intensifies.",
                "Local church raises money for medical aid.",
                "Tis the season. Christmas decorations are going up all over town.",
                "Menorah lighting at local synagogue.",
                "People going door singing Festivus songs."
            ]
            
            return options[Random(index: options.count)];
            
        case "Video Games":
            let options: [String] = [
                "Journalist uncovers lengthy \"death march\" practice at local video game studio.",
                "Yet again violence in video games is at the fore of the public's conversation.",
                "New mobile game topping the charts."
            ]
            
            return options[Random(index: options.count)];
            
        case "Technology":
            let options: [String] = [
                "Fancy gizmos are being invented around the world."
            ]
            
            return options[Random(index: options.count)];
            
        case "Music":
            let options: [String] = [
                "Groovy tunes are making the world's booty shake."
            ]
            
            return options[Random(index: options.count)];
            
        default:
            return "Ain't nothing going on out there.";
        }
    }
    
    final private func lifetime() -> Int {
        switch _NEWS_TOPIC.getName() {
        case "Conservatism":
            return Simulation.TICKS_PER_DAY;
        case "Liberalism":
            return Simulation.TICKS_PER_DAY;
        case "Children":
            return Simulation.TICKS_PER_DAY;
        case "Violence":
            return Simulation.TICKS_PER_DAY * 2;
        case "Education":
            return Simulation.TICKS_PER_DAY;
        case "Theatre":
            return Simulation.TICKS_PER_DAY;
        case "Travel":
            return Simulation.TICKS_PER_DAY;
        case "Sports":
            return Simulation.TICKS_PER_DAY;
        case "Film":
            return Simulation.TICKS_PER_DAY;
        case "Science":
            return Simulation.TICKS_PER_DAY;
        case "Religion":
            return Simulation.TICKS_PER_DAY;
        case "Video Games":
            return Simulation.TICKS_PER_DAY;
        case "Technology":
            return Simulation.TICKS_PER_DAY;
        case "Music":
            return Simulation.TICKS_PER_DAY;
        default:
            return Simulation.TICKS_PER_DAY;
        }
    }
}

class EmployeeEvent: Event {
    init(message: String) {
        super.init(message: message, color:#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), symbol: "👤", lifetime: Simulation.TICKS_PER_DAY / 3);
    }
}

class ApplicantEvent: Event {
    init(message: String) {
        super.init(message: message, color: #colorLiteral(red: 0.5624527335, green: 0.9134209752, blue: 0.9260821939, alpha: 1), symbol: "📥", lifetime: Simulation.TICKS_PER_DAY / 3);
    }
}

class CompanyEvent: Event {
    init(message: String) {
        super.init(message: message, color: #colorLiteral(red: 0.9059416652, green: 0.9005564451, blue: 0.910081327, alpha: 1), symbol: "🏛", lifetime: Simulation.TICKS_PER_DAY / 4);
    }
}

class RegionEvent: Event {
    init(message: String) {
        super.init(message: message, color: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), symbol: "👓", lifetime: Simulation.TICKS_PER_DAY / 3);
    }
}
