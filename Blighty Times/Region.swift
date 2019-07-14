//
//  Region.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/26/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import GameplayKit

class Region {
    private let _SIZE: Int
    private let _TOPICS: [Topic]
    private var _newsTopic: Topic? = nil
    private var _releventTopics: [Topic] { return _newsTopic != nil ? [_newsTopic!] : _TOPICS }
    private let _MAX_LOYALTY: Double = 1.5
    private let _MIN_LOYALTY: Double = 0.015
    private let _LOYALTY_INCREMENT: Double = 0.05
    
    private var _loyalty: Double = 0.5
    var loyalty: Double { return _loyalty }
    private var _subscribers: Int
    private var _newSubscribers: Int = 0
    private var _daysSinceLastApproval: Int = 0
    private var _missedDeadline: Bool = false
    
    init(with officeSize: OfficeSize, excludedTopics: [Topic]?) {
        let topicCount = officeSize == .huge ? 3 : officeSize.rawValue + 1
        
        _SIZE = 100000 * ((officeSize.rawValue + 1) * 3)
        _TOPICS = Region.randomTopics(count: topicCount, excludedTopics: excludedTopics)
        _subscribers = 0
    }
    
    init(withSubs: Bool) {
        _SIZE = Region.randomSize()
        _TOPICS = Region.randomTopics()
        _subscribers = withSubs ? Region.randomStartingSubs(withRegion: _SIZE) : 0
    }
    
    init(size: Int, topics: [Topic], startWithSubs: Bool) {
        _SIZE = size
        _TOPICS = topics
        _subscribers = startWithSubs ? Region.randomStartingSubs(withRegion: _SIZE) : 0
    }
    
    func tick(published articles: [Article], isEarly: Bool) {
        var topicsLiked: Int = 0
        var sum: Int = 0
        var blankArticles: Int = 0
        
        for article in articles {
            if approves(of: article) {
                topicsLiked += 1
            }
            
            if article === ArticleLibrary.blank {
                blankArticles += 1
            } else {
                //The sum of qualities must not include the '1s' from the blank articles
                sum += article.getQuality()
            }
        }
        
        _missedDeadline = blankArticles == 6 ? true : false
        setNewSubs(statuses: topicsLiked, isEarly, sum > 0 ? Double(sum) / Double(6 - blankArticles) : 0.0)
    }
    
    func setNewsTopic(_ topic: Topic?) {
        _newsTopic = topic
    }
    
    func setNewSubs(statuses topicsLiked: Int, _ isEarly: Bool, _ averageQuality: Double) {
        let daysSinceApproval = Double(_daysSinceLastApproval)
        let subs = Double(_subscribers)
        let size = Double(_SIZE)
        
        //This checks for 0 and being greater than 1
        let loyalty: Double = _loyalty == 0 ? 0.00001 : _loyalty > 1 ? 1 : _loyalty
        
        //daysSinceLastApproval is set in setNewLoyalty().
        //Use daysSinceApproval below
        setNewLoyalty(from: topicsLiked, isEarly)
        
        /*
         - if the deadline was missed
         + Random(-1 ... 1000 * (2 if NewsEvent)) / loyalty
         - if they didnt like any article
         + Random(-500 * (2+daysSinceApproval if NewsEvent else daysSinceApproval) ... 500 * (0 if NewsEvent else averageQuality)) * loyalty
         - if they liked at least one article:
         + Random(1 * (2+quality if NewsEvent else quality) ... 1000 * (2+quality if NewsEvent else quality)) * loyalty
         */
        
        var newSubs: Double = 0.0
        
        if _missedDeadline {
            newSubs = -Double.random(in: pow(2, daysSinceApproval)
                ... pow(10, daysSinceApproval))
        } else if topicsLiked == 0 {
            newSubs = Double.random(in: -5000 * (daysSinceApproval * 2)
                ... 5000 * (_newsTopic == nil ? 0 : averageQuality))
        } else {
            newSubs = Double.random(in: 1000 * Double(_newsTopic == nil ? topicsLiked : topicsLiked * 2) * averageQuality
                ... 10000 * Double(_newsTopic == nil ? topicsLiked : topicsLiked * 2) * averageQuality)
        }
        
        print("Region's loyalty: \(_loyalty)")
        if newSubs > 0 {
            newSubs *= loyalty
        } else if newSubs < 0 {
            newSubs /= loyalty
        }
        
        //This ensures that new subscribers are never so negative that it would
        //bring total subscriber count to less than 0 & likewise that it's never
        //so positive that it brings total subscriber count to greater than the region size
        if subs + newSubs < 0 {
            newSubs = -subs
        } else if subs + newSubs > size {
            newSubs = size - subs
        }
        
        _missedDeadline = false
        _newSubscribers = Int(newSubs)
        _subscribers += _newSubscribers
    }
    
    func setNewLoyalty(from topicsLiked: Int, _ isEarly: Bool) {
        if topicsLiked > 0 {
            increaseLoyalty(by: topicsLiked)
            _daysSinceLastApproval = 0
            
            if isEarly { increaseLoyalty(by: 1) }
        } else {
            reduceLoyalty(by: 1)
            _daysSinceLastApproval += 1
        }
        
        if _daysSinceLastApproval > 7 {
            reduceLoyalty(by: 2)
        }
        
        if _missedDeadline {
            reduceLoyalty(by: 1)
        }
    }
    
    func increaseLoyalty(by increments: Int) {
        //Commented out the ternary expression which disallows _loyalty to go beyond its maximum
        //I'm allowing it to go above the max so that reducing loyalty takes longer
        _loyalty = _loyalty + (_LOYALTY_INCREMENT * Double(increments))// < _MAX_LOYALTY
        //? _loyalty + (_LOYALTY_INCREMENT * Double(increments))
        //: _MAX_LOYALTY
    }
    
    func increaseLoyalty(divide numerator: Int, by denominator: Int) {
        if numerator > 0 && denominator > 0 {
            let newIncrement = (_LOYALTY_INCREMENT * (Double(numerator) / Double(denominator)))
            
            _loyalty = _loyalty + newIncrement < _MAX_LOYALTY
                ? _loyalty + (_LOYALTY_INCREMENT * newIncrement)
                : _MAX_LOYALTY
        } else {
            increaseLoyalty(by: 1)
            print("Invalid fraction given to increaseLoyalty(divide: \(numerator), by: \(denominator)")
        }
    }
    
    func reduceLoyalty(by increments: Int) {
        _loyalty = _loyalty - (_LOYALTY_INCREMENT * Double(increments)) > _MIN_LOYALTY
            ? _loyalty - (_LOYALTY_INCREMENT * Double(increments))
            : _MIN_LOYALTY
    }
    
    func getSize() -> Int {
        return _SIZE
    }
    
    func getTotalSubscriberCount() -> Int {
        return _subscribers
    }
    
    func getNewSubscriberCount() -> Int {
        return _newSubscribers
    }
    
    func getApprovalSymbol() -> String {
        if _loyalty <= _MIN_LOYALTY + (_LOYALTY_INCREMENT * 3) {
            return "☠︎"
        } else if _loyalty >= _MAX_LOYALTY - (_LOYALTY_INCREMENT * 3) {
            return "❤︎"
        }
        
        return ""
    }
    
    func getTopics() -> [Topic] {
        return _releventTopics
    }
    
    func hasHighLoyalty() -> Bool {
        return _loyalty >= 1
    }
    
    private func approves(of article: Article) -> Bool {
        for t in _releventTopics {
            if t.name == article.getTopic().name {
                return true
            }
        }
        
        return false
    }
    
    private static func randomSize() -> Int {
        return Int.random(in: 100000 ... 1000000)
    }
    
    private static func randomTopics(count: Int, excludedTopics: [Topic]?) -> [Topic] {
        return TopicLibrary.getRandomTopics(count: count, excludedTopics: excludedTopics)
    }
    
    private static func randomTopics() -> [Topic] {
        return TopicLibrary.getRandomTopics()
    }
    
    private static func randomStartingSubs(withRegion size: Int) -> Int {
        return Int.random(in: 0 ... size)
    }
}
