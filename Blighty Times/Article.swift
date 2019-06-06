//
//  Article.swift
//  BlightyTimes
//
//  Created by Zachary Duncan on 8/28/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import Foundation

class Article {
    private var _title: String;
    private var _topic: Topic;
    private var _author: Author;
    private var _quality: Int;
    private var _lifetime: Double = Double(Simulation.TICKS_PER_DAY) * 2; //Starts with default value and is modified by world events
    private var _inNextEdition: Bool = false;
    
    init(topic: Topic, author: inout Author, lifeMultiplier: Double = 1.0) {
        _title = topic.name
        _topic = topic;
        _author = author;
        _quality = author.getQuality();
        _lifetime *= lifeMultiplier;
    }
    
    func tick() {
        _lifetime -= 1;
    }
    
    func publish() {
        _author.publishArticle();
    }
    
    func addToNextEdition() {
        _inNextEdition = true;
    }
    
    func removeFromNextEdition() {
        _inNextEdition = false;
    }
    
    func isInNextEdition() -> Bool {
        return _inNextEdition;
    }
    
    func getTitle() -> String {
        return _title;
    }
    
    func getAuthor() -> Author {
        return _author;
    }
    
    func getTopic() -> Topic {
        return _topic;
    }
    
    func getQuality() -> Int {
        return _quality;
    }
    
    func getLifetime() -> Double {
        return _lifetime;
    }
}

class ArticleLibrary {
    static let blank: Article = Article(topic: TopicLibrary.blank, author: &AuthorLibrary().blank);
}





