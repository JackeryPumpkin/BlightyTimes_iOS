//
//  Population.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 10/11/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import Foundation

class Population {
    private var _regions: [Region?] = [];
    var regions: [Region?] { return _regions }
    
    private var _yesterdaysNewSubs: Int = 0;
    private var _subscriberFluxuationThisWeek: Int = 0;
    
    init(from officeSize: OfficeSize) {
        let office = Office(size: officeSize)
        
        for _ in 1 ... office.regionCount { _regions.append(Region(with: officeSize, excludedTopics: nil)) }
        for _ in office.regionCount ..< 4 { _regions.append(nil) }
    }
    
    init() {
        for _ in 1 ... 4 { _regions.append(Region(withSubs: true)) }
        
        //TEST:
        //for _ in 1 ... 4 { _regions.append(Region(size: 1000000, topics: [TopicLibrary.list[0]], startWithSubs: true)) }
    }
    
    init(regions: Region ...) {
        for region in regions { _regions.append(region); }
    }
    
    func tick(published articles: [Article], is early: Bool) {
        for region in _regions {
            if let region = region {
                region.tick(published: articles, isEarly: early)
            }
        }
        
        _yesterdaysNewSubs = getNewSubscriberCount();
        _subscriberFluxuationThisWeek += _yesterdaysNewSubs;
    }
    
    func spreadNews(_ topic: Topic?) {
        for region in regions {
            if let region = region {
                region.setNewsTopic(topic)
            }
        }
    }
    
    func getTotalSubscriberCount() -> Int {
        var total = 0
        
        for region in _regions {
            if let region = region {
                total += region.getTotalSubscriberCount()
            }
        }
        
        return total;
    }
    
    func getNewSubscriberCount() -> Int {
        var new = 0;
        
        for region in _regions {
            if let region = region {
                new += region.getNewSubscriberCount()
            }
        }
        
        return new;
    }
    
    func getSubscriberFluxuationThisWeek() -> Int {
        return _subscriberFluxuationThisWeek;
    }
    
    func weeklyReset() {
        _subscriberFluxuationThisWeek = 0;
    }
    
    func overwriteRegion(at index: Int, with region: Region) {
        _regions[index] = region
    }
}
