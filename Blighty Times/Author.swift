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
    private var _experience: Double;
    private var _currentLevel: Int = 1;
    private var _topics: [Topic];
    private var _articleRate: Double;
    private var _articleProgress: Double = 0;
    private var _articlesPublishedThisWeek: Int = 0;
    private var _articlesWrittenThisWeek: Int = 0;
    private var _daysEmployed: Int = 0; //Their salary raises every 15 days.
    private var _morale: Int = 800; //Lowers when no articles published for # of ticks, raises when published, lowers slowly every day
    private var _lastKnownGameDaysElapsed: Int = 0;
    private var _salary: Int; //daily
    private var _commission: Int; //per publication
    
    //Morale Bonus Properties
    private var _paycheckBonus = 0;
    
    //Constants
    public let PROGRESS_MAX: Double = 100;
    public static let ARTICLE_RATE_MAX: Double = 1.0;
    public static let ARTICLE_RATE_MIN: Double = 0.3;
    
    //Handles the inits for the pre-made Authors with random stats
    //Used by AuthorLibrary
    fileprivate init(portrait: UIImage, name: String, topics: [Topic], articleRate: Double) {
        _portrait = portrait;
        _name = name;
        _experience = 0;
        _topics = topics;
        _articleRate = articleRate;
        _salary = Int(articleRate * 300);
        _commission = _salary * 2;
    }
    
    //Is the public interface for making new Authors in context of the currently employed
    init(exluding employedAuthors: inout [Author]) {
        let newAuthor = AuthorLibrary.getRandom(employedAuthors: &employedAuthors);
        _portrait = newAuthor.getPortrait();
        _name = newAuthor.getName();
        _experience = 0;
        _topics = newAuthor.getTopics();
        _articleRate = newAuthor.getRate();
        _salary = newAuthor.getSalary();
        _commission = newAuthor.getCommission();
    }
    
    func tick(elapsed days: Int) {
        if _lastKnownGameDaysElapsed != days {
            _lastKnownGameDaysElapsed = days;
            _daysEmployed += 1;
            adjustMorale();
        }
        
        promoteIfNecessary();
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
    
    func getSeniorityLevel() -> Int {
        return Int((sqrt(100.0 * (2.0 * _experience + 25.0)) + 50.0) / 100.0);
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
    
    private func increaseArticleProgress() {
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
        if _paycheckBonus == 0 {
            if _morale < 80 {
                return "🤬";
            } else if _morale < 200 {
                return "😡";
            } else if _morale < 300 {
                return "😤";
            } else if _morale < 500 {
                return "☹️";
            } else if _morale < 600 {
                return "😐";
            } else if _morale < 801 {
                return "😀";
            } else {
                return "🤩";
            }
        } else {
            return "🤑";
        }
    }
    
    private func adjustMorale() {
        if _paycheckBonus == 0 {
            if _daysEmployed > 7 {
                _morale -= 50;
                
                if _articlesPublishedThisWeek < 1 {
                    _morale -= 50;
                }
            } else if _daysEmployed > 30 {
                _morale -= 200;
            }
        } else {
            _paycheckBonus -= 1;
        }
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
        increaseExperience();
        _paycheckBonus = 1;
    }
    
    func getSubmittedThisWeek() -> Int {
        return _articlesWrittenThisWeek;
    }
    
    func submitArticle() {
        _articlesWrittenThisWeek += 1;
        _articleProgress = 0;
        increaseExperience();
        _paycheckBonus = 1;//Only while publishing is not implemented
    }
    
    func getExperience() -> Double {
        return _experience;
    }
    
    func increaseExperience() {
        _morale += 10;
        _experience += 50;
    }
    
    func promoteIfNecessary() {
        if getSeniorityLevel() != _currentLevel {
            //Increases rate by a 10th of the difference between the min and max rates
            let rateIncrease: Double = (Author.ARTICLE_RATE_MAX - Author.ARTICLE_RATE_MIN) / 10.0;
            _articleRate = _articleRate + rateIncrease > Author.ARTICLE_RATE_MAX ? Author.ARTICLE_RATE_MAX : _articleRate + rateIncrease;
            
            //Increases salary based on rate
            _salary = _articleRate == Author.ARTICLE_RATE_MAX ? _salary + 10 : Int(_articleRate * 300);
            _commission = _salary * 2;
            
            _currentLevel = getSeniorityLevel();
        }
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
        Author(portrait: #imageLiteral(resourceName: "Author5"), name: "Hank Prestal", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author1"), name: "Jerome Filks", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author8"), name: "Justin Hestile", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author6"), name: "Marie Gilphon", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author4"), name: "Emma Venbracket", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author6"), name: "Charlotte Klumph", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author7"), name: "Ava Estmire", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author9"), name: "Ike Crimmelflank", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate()),
        Author(portrait: #imageLiteral(resourceName: "Author5"), name: "Bill Festerville", topics: TopicLibrary.getRandomTopics(), articleRate: getRandomRate())
    ];
    
    var blank: Author = Author(portrait: UIImage(), name: "blank", topics: [], articleRate: 0);
    
    fileprivate static func getRandom(employedAuthors: inout [Author]) -> Author {
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
    
    static func getRandomRate() -> Double {
        return Random(double: Author.ARTICLE_RATE_MIN ... Author.ARTICLE_RATE_MAX);
    }
}

