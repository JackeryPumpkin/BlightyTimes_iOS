//
//  Author.swift
//  BlightyTimes
//
//  Created by Zachary Duncan on 8/19/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import UIKit;

class Author {
    private var _portrait: UIImage;
    private var _name: String;
    private var _level: Int;
    private var _topics: [Topic];
    private var _articleRate: Double;
    private var _articleProgress: Double = 0;
    private var _articlesPublishedThisWeek: Int = 0;
    private var _articlesWrittenThisWeek: Int = 0;
    private var _daysEmployed: Int = 0; //Their salary raises every 15 days.
    private var _morale: Int = 800; //Lowers when no articles published for # of ticks, raises when published, lowers slowly every day
    private var _lastKnownGameDaysElapsed: Int = 0;
    private var _salary: Int = 275; //daily
    private var _commission: Int = 1000; //per publication
    
    public let PROGRESS_MAX: Double = 100;
    public static let ARTICLE_RATE_MAX: Double = 0.8;
    public static let ARTICLE_RATE_MIN: Double = 0.05;
    
    fileprivate init(portrait: UIImage, name: String, topics: [Topic], articleRate: Double) {
        _portrait = portrait;
        _name = name;
        _level = 1;
        _topics = topics;
        _articleRate = articleRate;
    }
    
    init(exluding employedAuthors: inout [Author]) {
        let newAuthor = AuthorLibrary.getRandom(employedAuthors: &employedAuthors);
        _portrait = newAuthor.getPortrait();
        _name = newAuthor.getName();
        _level = newAuthor.getLevel();
        _topics = newAuthor.getTopics();
        _articleRate = newAuthor.getRate();
    }
    
    func tick(elapsed days: Int) {
        if _lastKnownGameDaysElapsed != days {
            _lastKnownGameDaysElapsed = days;
            _daysEmployed += 1;
            adjustMorale();
        }
        
        increaseArticleProgress();
    }
    
    func newWeekReset() {
        _articlesWrittenThisWeek = 0;
        _articlesPublishedThisWeek = 0;
    }
    
    func getPortrait() -> UIImage {
        return _portrait;
    }
    
    func getName() -> String {
        return _name;
    }
    
    func getLevel() -> Int {
        return _level;
    }
    
    func getRate() -> Double {
        return _articleRate;
    }
    
    func getRateSymbol() -> String {
        let difference = Author.ARTICLE_RATE_MAX - Author.ARTICLE_RATE_MIN;
        
        if _articleRate < Author.ARTICLE_RATE_MIN + (difference * 0.25) {
            return "+";
        } else if _articleRate < Author.ARTICLE_RATE_MIN + (difference * 0.50) {
            return "++";
        } else if _articleRate < Author.ARTICLE_RATE_MIN + (difference * 0.75) {
            return "+++";
        } else {
            return "++++";
        }
    }
    
    func getBonus() -> String {
        return "Article Speed ++";
    }
    
    func getTopics() -> [Topic] {
        return _topics;
    }
    
    func getArticalProgress() -> Double {
        return _articleProgress > PROGRESS_MAX ? PROGRESS_MAX : _articleProgress;
    }
    
    func increaseArticleProgress() {
        if _articleProgress < PROGRESS_MAX {
            _articleProgress += _articleRate;
        }
    }
    
    func hasFinishedArticle() -> Bool {
        return getArticalProgress() == PROGRESS_MAX;
    }
    
    func getDaysEmployed() -> Int {
        return _daysEmployed
    }
    
    func getMorale() -> Int {
        return _morale;
    }
    
    func getMoraleSymbol() -> String {
        if _morale < 80 {
            return "🤬";
        } else if _morale < 100 {
            return "😤";
        } else if _morale < 300 {
            return "😠";
        } else if _morale < 400 {
            return "😖";
        } else if _morale < 500 {
            return "☹️";
        } else if _morale < 600 {
            return "😐";
        } else if _morale < 801 {
            return "😀";
        } else {
            return "🤩";
        }
    }
    
    func adjustMorale() {
        if _daysEmployed > 7 {
            _morale -= 10;
            
            if _articlesPublishedThisWeek < 1 {
                _morale -= 10;
            }
        } else if _daysEmployed > 30 {
            _morale -= 50;
        }
        
        _morale += _articlesPublishedThisWeek * 10;
    }
    
    func getSalary() -> Int {
        return _salary;
    }
    
    func getCommission() -> Int {
        return _commission;
    }
    
    func getPublishedThisWeek() -> Int {
        return _articlesPublishedThisWeek;
    }
    
    func publishArticle() {
        _articlesPublishedThisWeek += 1;
    }
    
    func getSubmittedThisWeek() -> Int {
        return _articlesWrittenThisWeek;
    }
    
    func submitArticle() {
        _articlesWrittenThisWeek += 1;
        _articleProgress = 0;
    }
    
    func newArticleTopic() -> Topic {
        return _topics[Random(index: _topics.count)];
    }
}

class AuthorLibrary {
    private static let _AUTHORS: [Author] = [
        Author(portrait: #imageLiteral(resourceName: "Author7"), name: "Suzy Joe", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author9"), name: "Snazzy Jack Bricklayer", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author3"), name: "Frank Bottomwealth", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author5"), name: "Harold Knickers", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author6"), name: "Theresa Frost", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author8"), name: "Lincoln Mathers", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author1"), name: "Freddie Plicks", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author4"), name: "Wendy Mysten", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author2"), name: "Elaine Mendihooks", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author3"), name: "Chuck Vandel", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author8"), name: "Greg R.E. House", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author1"), name: "Jesse Flickmaster", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author6"), name: "Nichole Tremble", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author5"), name: "Leonard Spray", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author4"), name: "Catherine Humble", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author9"), name: "Samuel Barth", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author7"), name: "Jackie Westerpile", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author3"), name: "Pete Underknuckle", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author1"), name: "Arthur Tinmonk", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author8"), name: "Richard Feak", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author5"), name: "Timothy Whiskers", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author3"), name: "Matthew Snore", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author6"), name: "Brittany Blossoms", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author9"), name: "Nigel Tuntilly", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author1"), name: "James Heath", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author8"), name: "Norman Sugar", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author6"), name: "Lizzy Frankly", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author8"), name: "Osmund Honey", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author3"), name: "Terry Smackeral", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author5"), name: "Oliver Klipfil", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author4"), name: "Abbigail Mowrett", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author2"), name: "Jen Thistlebeak", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author5"), name: "Bill Festerville", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate())
    ];
    
    var blank: Author = Author(portrait: UIImage(), name: "blank", topics: [], articleRate: 0);
    
    fileprivate static func getRandom(employedAuthors: inout [Author]) -> Author {
        //print("get random author name");
        var rAuthor = AuthorLibrary._AUTHORS[Random(index: AuthorLibrary._AUTHORS.count)];
        
        var valid = false;
        while (!valid) {
            valid = true;
            
            for author in employedAuthors {
                if (author.getName() == rAuthor.getName()) {
                    rAuthor = AuthorLibrary._AUTHORS[Random(index: AuthorLibrary._AUTHORS.count)];
                    valid = false;
                }
            }
        }
        
        return rAuthor;
    }
    
    private static func getRandomRate() -> Double {
        //print("get random author article rate");
        return Random(double: Author.ARTICLE_RATE_MIN ... Author.ARTICLE_RATE_MAX);
    }
    
}

