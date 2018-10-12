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
    
    init() {
        _SIZE = RegionHelper.randomSize();
        _TOPICS = RegionHelper.randomTopics();
        _subscribers = 0;
    }
    
    init(size: Int, topics: [Topic], startWithSubs: Bool) {
        _SIZE = size;
        _TOPICS = topics;
        _subscribers = startWithSubs ? RegionHelper.randomStartingSubs(withRegion: _SIZE) : 0;
    }
    
    func dailyTick(published articles: [Article], is early: Bool) {
        var topicsLiked: Int = 0;
        let isWorldEventTopic = false; //temporary until WorldEvents.relatedTopic() is added
        
        _newSubscribers = 0;
        
        //Find the level of approval this region has of the
        //recently published article topics
        for article in articles {
            var approval = -1.0;
            if approves(of: article) {
                topicsLiked += 1;
                approval = 1.0;
            }
            
            // Include other variables to new subs calculation:
            // - Early publication (people appreciate prompt service (add this as a "News" update to let the player know))
            // - Regular updates (people don't want to wait too long)
            let size: Double = Double(_SIZE);
            let loyalty: Double = _loyalty > 3 ? 0.0001 : 0;
            let quality: Double = Double(article.getQuality()) / 10000;
            let eventMult: Double = isWorldEventTopic ? 2.0 : 1.0;
            let earlyBonus: Double = early ? Double(_SIZE) / 500000 : 0;
            
            _newSubscribers += Int((((size * (loyalty + quality)) * eventMult) + earlyBonus) * approval);
        }
        
        //Determine new loyalty
        if topicsLiked > 0 {
            _loyalty += (Double(topicsLiked) / Double(_TOPICS.count)) * 0.1;
            _daysSinceLastApproval = 0;
        } else {
            _loyalty -= _loyalty - 0.05 > 0 ? 0.05 : 0;
        }
        
        //Determine new total subscriber count based on loyalty & topicsLiked
        //        if _loyalty <= 0.5 {
        //            if topicsLiked > 0 {
        //                _newSubscribers = Int((Double(topicsLiked) / Double(_TOPICS.count)) * sqrt(Double(_SIZE / 2)));
        //            } else {
        //                _newSubscribers = -Int(Random(double: 0.5 ... 0.9) * sqrt(Double(_subscribers)));
        //            }
        //        } else if _loyalty <= 1.0 {
        //            if topicsLiked > 0 {
        //                _newSubscribers = Int((Double(topicsLiked) / Double(_TOPICS.count)) * sqrt(Double(_SIZE))) + 10;
        //            } else {
        //                _newSubscribers = -Int(Random(double: 0.1 ... 0.4) * sqrt(Double(_subscribers)));
        //            }
        //        } else {
        //            if topicsLiked > 0 {
        //                _newSubscribers = Int((Double(topicsLiked) / Double(_TOPICS.count)) * sqrt(Double(_SIZE))) + 50;
        //            } else {
        //                _newSubscribers = 0;
        //            }
        //        }
        
        if _newSubscribers + _subscribers <= _SIZE {
            if _subscribers + _newSubscribers < 0 {
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
            _loyalty -= _loyalty - 0.05 > 0 ? 0.05 : 0;
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
        return Random(int: 300000 ... 2000000);
    }
    
    static func randomTopics() -> [Topic] {
        return TopicLibrary.getRandomTopics();
    }
    
    static func randomStartingSubs(withRegion size: Int) -> Int {
        return Random(int: 0 ... size);
    }
}
