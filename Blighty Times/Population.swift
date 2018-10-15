//
//  Population.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 10/11/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import Foundation

class Population {
    private var _regions: [Region] = [];
            var regions: [Region] { return _regions; }
    
    private var _yesterdaysNewSubs: Int = 0;
    
    init() {
        for _ in 1 ... 4 { _regions.append(Region()); }
    }
    
    init(regions: Region ...) {
        for region in regions { _regions.append(region); }
    }
    
    func tick(published articles: [Article], is early: Bool) {
        for region in _regions {
            print("Region's topics: ")
            region.dailyTick(published: articles, is: early);
        }
        
        _yesterdaysNewSubs = getNewSubscriberCount();
        
        print("\n\n");
    }
    
    func getTotalSubscriberCount() -> Int {
        var total = 0
        
        for region in _regions {
            total += region.getTotalSubscriberCount();
        }
        
        return total;
    }
    
    func getNewSubscriberCount() -> Int {
        var new = 0;
        
        for region in _regions {
            new += region.getNewSubscriberCount();
        }
        
        return new;
    }
}


class Region {
    private let _SIZE: Int;
    private let _TOPICS: [Topic];
    
    private var _loyalty: Double = 0;
    private var _subscribers: Int;
    private var _newSubscribers: Int = 0;
    private var _daysSinceLastApproval: Int = 0;
    private var _earlyBonus: Double = 1;
    private var _incomplete: Bool = false;
    
    init() {
        _SIZE = RegionHelper.randomSize();
        _TOPICS = RegionHelper.randomTopics();
        _subscribers = _SIZE / 4;
    }
    
    init(size: Int, topics: [Topic], startWithSubs: Bool) {
        _SIZE = size;
        _TOPICS = topics;
        _subscribers = startWithSubs ? RegionHelper.randomStartingSubs(withRegion: _SIZE) : 0;
    }
    
    func dailyTick(published articles: [Article], is early: Bool) {
        for topic in _TOPICS { print(topic.getApprovalSymbol() + topic.getName()); }
        
        var topicsLiked: Int = 0;
        let isWorldEventTopic = false; //temporary until WorldEvents.relatedTopic() is added
        let size: Double = Double(_SIZE);
        let loyalty = (sqrt(100.0 * (2.0 * _loyalty + 25.0)) + 50.0) / 100.0;
        let eventMult: Double = isWorldEventTopic ? 2.0 : 1.0;
        let unsubcribed: Double = size - Double(_subscribers) > 0 ? size - Double(_subscribers) : 0;
        var quality: Double = 0;
        _earlyBonus = early ? sqrt(unsubcribed) / 2 : 1;
        
        _newSubscribers = 0;
        
        for article in articles {
            
            quality += Double(article.getQuality());
            
            
            if approves(of: article) {
                topicsLiked += 1;
                
//                _newSubscribers += Random(between: Int(sqrt(unsubcribed) / loyalty * quality), and: Int(eventMult * sqrt(unsubcribed)));
                
                
            } else {
                _newSubscribers -= 1;
            }
            
            
        }
        
        _newSubscribers += Int((sqrt((Double(topicsLiked + 1) * 16) * (loyalty * unsubcribed + 25.0)) + _earlyBonus) / (100.0 * eventMult) * quality);
        print("sqrt((\(topicsLiked) * \(quality)) * (\(loyalty) * \(unsubcribed) + 25.0)) + \(_earlyBonus)) / (100.0 * \(eventMult))");
        
//        if _incomplete {
//            if _newSubscribers > 0 { _newSubscribers /= 6; }
//        } else {
//            _newSubscribers /= 6 - topicsLiked;
//        }
//
//        if topicsLiked == 0 {
//            _newSubscribers -= Int((sqrt(100.0 * (loyalty * Double(_subscribers) + 25.0)) + _earlyBonus) / 100.0);
//        } else if topicsLiked <= 3 {
//
//        } else {
//
//        }
        
        print("NEW SUBSCRIBERS: \(_newSubscribers)")
        if _loyalty < 15 {
            
        } else if _loyalty < 50 {
            if _newSubscribers < 0 { _newSubscribers /= 2; }
        } else if _loyalty < 125 {
            if _newSubscribers < 0 { _newSubscribers /= 4; }
        } else if _loyalty < 250 {
            if _newSubscribers < 0 { _newSubscribers = (_newSubscribers * -1) / 2 }
        } else if _loyalty < 400 {
            if _newSubscribers < 0 { _newSubscribers *= -1; }
        } else {
            if _newSubscribers < 0 { _newSubscribers = Int(sqrt(Double(_subscribers))); }
        }
        
        //Determine new loyalty
        if topicsLiked > 0 {
            _loyalty += (Double(topicsLiked) / Double(_TOPICS.count)) * 60;
            _daysSinceLastApproval = 0;
        } else {
            _loyalty = _loyalty - 5 > 0 ? _loyalty - 5 : 0;
        }
        
        if _newSubscribers + _subscribers <= _SIZE {
            if _subscribers + _newSubscribers <= 0 {
                _newSubscribers = _subscribers;
                _subscribers = 0;
            } else {
                _subscribers += _newSubscribers;
            }
        } else {
            _newSubscribers = _SIZE - _subscribers;
            _subscribers = _SIZE;
        }
        
        print("Region has \(_subscribers) subscribers out of \(_SIZE) people total");
        
        if _daysSinceLastApproval > 7 {
            _loyalty = _loyalty - 5 > 0 ? _loyalty - 5 : 0;
        }
        
        _daysSinceLastApproval += 1;
    }
    
    func getSize() -> Int {
        return _SIZE;
    }
    
    func getTotalSubscriberCount() -> Int {
        return _subscribers;
    }
    
    func getNewSubscriberCount() -> Int {
        return _newSubscribers;
    }
    
    func getApprovalSymbol() -> String {
        if _loyalty <= 0.5 {
            return "☠︎";
        } else if _loyalty > 1.0 {
            return "❤︎";
        }
        
        return "";
    }
    
    func getTopics() -> [Topic] {
        return _TOPICS;
    }
    
    private func approves(of article: Article) -> Bool {
        for t in _TOPICS {
            if t.getApproval() == article.getTopic().getApproval() &&
               t.getName() == article.getTopic().getName() {
                return true;
            }
        }
        
        return false;
    }
}


class RegionHelper {
    static func randomSize() -> Int {
        return Random(int: 100000 ... 1000000);
    }
    
    static func randomTopics() -> [Topic] {
        return TopicLibrary.getRandomTopics();
    }
    
    static func randomStartingSubs(withRegion size: Int) -> Int {
        return Random(int: 0 ... size);
    }
}
