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
    private var _subscriberFluxuationThisWeek: Int = 0;
    
    init() {
        for _ in 1 ... 4 { _regions.append(Region()); }
//        TEST:
//        for _ in 1 ... 4 { _regions.append(Region(size: 1000000, topics: [TopicLibrary.list[0]], startWithSubs: true)) }
    }
    
    init(regions: Region ...) {
        for region in regions { _regions.append(region); }
    }
    
    func tick(published articles: [Article], is early: Bool) {
        for region in _regions {
            region.tick(published: articles, isEarly: early);
        }
        
        _yesterdaysNewSubs = getNewSubscriberCount();
        _subscriberFluxuationThisWeek += _yesterdaysNewSubs;
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
    
    func getSubscriberFluxuationThisWeek() -> Int {
        return _subscriberFluxuationThisWeek;
    }
    
    func weeklyReset() {
        _subscriberFluxuationThisWeek = 0;
    }
}

import GameplayKit
class Region {
    private let _SIZE: Int;
    private let _TOPICS: [Topic];
    private let _MAX_LOYALTY: Double = 1.5;
    private let _MIN_LOYALTY: Double = 0.5;
    private let _LOYALTY_INCREMENT: Double = 0.01
    
    private var _loyalty: Double = 1.0;
    private var _subscribers: Int;
    private var _newSubscribers: Int = 0;
    private var _daysSinceLastApproval: Int = 0;
    private var _missedDeadline: Bool = false;
    
    init() {
        _SIZE = RegionHelper.randomSize();
        _TOPICS = RegionHelper.randomTopics();
        _subscribers = RegionHelper.randomStartingSubs(withRegion: _SIZE);
    }
    
    init(size: Int, topics: [Topic], startWithSubs: Bool) {
        _SIZE = size;
        _TOPICS = topics;
        _subscribers = startWithSubs ? RegionHelper.randomStartingSubs(withRegion: _SIZE) : 0;
    }
    
    func tick(published articles: [Article], isEarly: Bool) {
        var topicsLiked: Int = 0;
        var overallQuality: Int = 0;
        var blankArticles: Int = 0;
        
        for article in articles {
            if approves(of: article) {
                topicsLiked += 1;
                overallQuality += article.getQuality();
            }
            
            if article === ArticleLibrary.blank {
                blankArticles += 1;
            }
        }
        
        _missedDeadline = blankArticles == 6 ? true : false;
        setNewSubs(statuses: topicsLiked, isEarly, overallQuality);
        
        print("Subs: \(_subscribers), Size: \(_SIZE)");
    }
    
    func setNewSubs(statuses topicsLiked: Int, _ isEarly: Bool, _ overallQuality: Int) {
        let daysSinceApproval = Float(_daysSinceLastApproval);
        let quality = Float(overallQuality > 0 ? overallQuality : 1);
        let subs = Float(_subscribers);
        let size = Float(_SIZE);
        let loyalty = Float(_loyalty);
        
        setNewLoyalty(from: topicsLiked);
        
        let random = GKRandomSource();
        var newSubGen = GKGaussianDistribution();
        
        if !_missedDeadline {
            newSubGen = GKGaussianDistribution(randomSource: random,
                        mean: Float(topicsLiked > 1 ? topicsLiked : 1) * (1000 * quality) * (isEarly ? loyalty + 0.1 : loyalty) * (daysSinceApproval > 0 ? -daysSinceApproval: 1),
                        deviation: sqrtf(subs + 1) / 2 * Float(topicsLiked + 1));
        } else {
            newSubGen = GKGaussianDistribution(randomSource: random,
                        mean: Float(_daysSinceLastApproval) * -1000,
                        deviation: sqrtf(subs + 1) / 2 * daysSinceApproval);
        }
        
        var newSubs: Float = Float(newSubGen.nextInt());
        
        if newSubs >= 0 {
            newSubs *= loyalty;
        } else {
            newSubs /= loyalty;
        }
        
        if subs + newSubs < 0 {
            newSubs = -subs;
        } else if subs + newSubs > size {
            newSubs = size - subs;
        }
        
        _missedDeadline = false;
        _newSubscribers = Int(newSubs);
        _subscribers += _newSubscribers;
    }
    
    func setNewLoyalty(from topicsLiked: Int) {
        if topicsLiked > 0 {
            increaseLoyalty(divide: topicsLiked, by: 6);
            _daysSinceLastApproval = 0;
        } else {
            reduceLoyalty(by: 1);
            _daysSinceLastApproval += 1;
        }
        
        if _daysSinceLastApproval > 7 {
            reduceLoyalty(by: 2);
        }
        
        if _missedDeadline {
            reduceLoyalty(by: 1);
        }
    }
    
    func increaseLoyalty(by increments: Int) {
        _loyalty = _loyalty + (_LOYALTY_INCREMENT * Double(increments)) < _MAX_LOYALTY
                    ? _loyalty + (_LOYALTY_INCREMENT * Double(increments))
                    : _MAX_LOYALTY;
    }
    
    func increaseLoyalty(divide numerator: Int, by denominator: Int) {
        if numerator > 0 && denominator > 0 {
            let newIncrement = (_LOYALTY_INCREMENT * (Double(numerator) / Double(denominator)));
            
            _loyalty = _loyalty + newIncrement < _MAX_LOYALTY
                        ? _loyalty + (_LOYALTY_INCREMENT * newIncrement)
                        : _MAX_LOYALTY;
        } else {
            increaseLoyalty(by: 1);
            print("Invalid fraction given to increaseLoyalty(divide numerator: Int, by denominator: Int)");
        }
    }
    
    func reduceLoyalty(by increments: Int) {
        _loyalty = _loyalty - (_LOYALTY_INCREMENT * Double(increments)) > _MIN_LOYALTY
                    ? _loyalty - (_LOYALTY_INCREMENT * Double(increments))
                    : _MIN_LOYALTY;
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
        if _loyalty <= _MIN_LOYALTY + (_LOYALTY_INCREMENT * 3) {
            return "☠︎";
        } else if _loyalty >= _MAX_LOYALTY - (_LOYALTY_INCREMENT * 3) {
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
