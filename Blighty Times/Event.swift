//
//  Event.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 11/4/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import UIKit

class Event {
    let title: String
    var message: String
    let color: UIColor
    let image: UIImage
    var lifetime: Int
    var hasBeenShown: Bool = false
    var okayAction: (()->Void)?
    //let id: Int
    
    static let badColor: UIColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
    static let veryBadColor: UIColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
    static let goodColor: UIColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
    static let neutralColor: UIColor = #colorLiteral(red: 0.8451363548, green: 0.8862745166, blue: 0.8128135135, alpha: 1)
    
    init(title: String, message: String, color: UIColor, image: UIImage, lifetime: Int) {
        self.title = title
        self.message = message
        self.color = color
        self.image = image
        self.lifetime = lifetime
        
        //id = Int.random(in: 1 ... 10000)
    }
    
    convenience init() {
        self.init(title: "", message: "", color: UIColor(), image: UIImage(), lifetime: 0)
    }
    
    final func tick() {
        lifetime -= lifetime > 0 ? 1 : 0;
    }
}


class NewsEvent: Event {
    let topic: Topic
    
    init() {
        topic = TopicLibrary.getRandomTopics()[0]
        super.init(title: topic.name + " News", message: "", color: topic.color, image: topic.image, lifetime: 0)
        
        lifetime = lifetime()
        message = message()
    }
    
    final private func message() -> String {
        let options: [String]
        
        switch topic.name {
        case "Conservatism":
            options = [
                "Conservative politition embroiled in intense scandal.",
                "Conservative politition being celebrated for recent accomplishment.",
                "Results just in from conservative referendum, \"Let’s keep everything how we’ve had it.\""
            ]
            
        case "Liberalism":
            options = [
                "Liberal politition embroiled in intense scandal.",
                "Liberal politition being celebrated for recent accomplishment.",
                "Results just in from liberal referendum, \"Let’s change everything.\""
            ]
            
        case "Children":
            options = [
                "Nuclear \"incident\" near primary school.",
                "Blighty citizens are being harassed by an growing gang of children.",
                "Child prodigy starts at new position at NASA.",
                "Child prodigy plays violin with Tim Minchin in front of 10,000 people."
            ]
            
        case "Violence":
            options = [
                "Chuck Norris just gave an NRA talk at a local park.",
                "Martial arts classes are half off city-wide.",
                "Theft is becoming more and more common in Central Blighty.",
                "Crime is on the rise.",
                "UFC Match to be hosted in Blighty Square Garden.",
                "Everyone is talking about a viral video of two geese fighting over bread."
            ]
            
        case "Education":
            options = [
                "Standardized test scores are at an all-time low.",
                "Graduation rate is an all-time high at local schools.",
                "Elementary school school play given scathing reviews on Rotten Tomatoes",
            ]
            
        case "Theatre":
            options = [
                "Local theatre shutters its doors from lack of attendance.",
                "New satirical musical is a masterpiece, breaking sales records."
            ]
            
        case "Travel":
            options = [
                "The mayor of Blighty has put a travel ban on all flights to Babylon.",
                "A wild fire has sprung up preventing commuters traveling to the west.",
                "An upscale resort in the Caribbean is 50% off to all Blighty residents.",
                "Blighty's Got Talent is filming its finale in Springfield next week.",
                "\"One fish? Two fish. Red fish, blue fish.\" Oil spill causes thousands of fish wash up on Blighty's west coast."
            ]
            
        case "Sports":
            options = [
                "Blighty City Stadium will be hosting an American \"football\" game today.",
                "Blighty won 2 medals at the Olympics and they were bronze.",
                "Tickets to the West Blight vs Blighty United game have sold out.",
                "Another day goes by and still no one cares about fencing.",
                "Longest cricket match in Blighty history continues into its fifth day."
            ]
            
        case "Cinema":
            options = [
                "Stephen Fry is premiering a documentary on ravens and writing desks.",
                "New film by Quentin Tarantino is sparking an intense dialogue among viewers.",
                "Fawlty Towers is being made into a Hollywood film staring Tom Cruise.",
                "Lock, Stock and Three Smoking Barrels script details were leaked online."
            ]
            
        case "Science":
            options = [
                "Elon Musk showed a personal size rocket car that's powered by time.",
                "Richard Dawkins to give three live zoology presentations for kids."
            ]
            
        case "Religion":
            options = [
                "Religious conflict intensifies.",
                "Local church raises money for medical aid.",
                "Tis the season. Christmas decorations are going up all over town.",
                "Menorah lighting at local synagogue.",
                "People going door singing Festivus songs.",
                "Authorities search for a man who attained super powers from excessive thoughts and prayers."
            ]
            
        case "Video Games":
            options = [
                "Journalist uncovers lengthy \"death march\" practice at local video game studio.",
                "Yet again violence in video games is at the fore of the public's conversation.",
                "New mobile game topping the charts."
            ]
            
        case "Technology":
            options = [
                "Fancy gizmos are being invented around the world.",
                "New Kindle reading device releasing soon with a display made from wood paste and ink, needing no batteries.",
                "Next iPhone announced to come with six cameras, taking up too much room. Phone sold separately.",
                "How many people does it take to screw in a lightbulb? None, says local robot.",
                "Has the robot uprising already begun? \"Beep\" says enigmatic representative from Blighty Robotics."
            ]
            
        case "Music":
            options = [
                "Groovy tunes are making the world's booty shake."
            ]
            
        default:
            return "Ain't nothing going on out there.";
        }
        
        return options[Random(index: options.count)]
    }
    
    final private func lifetime() -> Int {
        switch topic.name {
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
    init(title: String, message: String, color: UIColor, image: UIImage) {
        super.init(title: title, message: message, color: color, image: image, lifetime: Simulation.TICKS_PER_DAY * 2)
    }
}

class CompanyEvent: Event {
    init(title: String, message: String, color: UIColor, image: UIImage) {
        super.init(title: title, message: message, color: color, image: image, lifetime: Simulation.TICKS_PER_DAY)
    }
}

class OfficeEvent: Event {
    init(title: String, message: String, color: UIColor, image: UIImage) {
        super.init(title: title, message: message, color: color, image: image, lifetime: Simulation.TICKS_PER_DAY / 4)
    }
}

class RegionEvent: Event {
    init(title: String, message: String, color: UIColor) {
        super.init(title: title, message: message, color: color, image: UIImage(), lifetime: Simulation.TICKS_PER_DAY / 4)
    }
}

class FiringEvent: Event {
    init(title: String, message: String, color: UIColor, image: UIImage, action: @escaping (()->Void)) {
        super.init(title: title, message: message, color: color, image: image, lifetime: Simulation.TICKS_PER_DAY / 4)
        okayAction = action
    }
}
