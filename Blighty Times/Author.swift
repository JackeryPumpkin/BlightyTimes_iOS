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
    private var _quality: Int;
    private var _articleRate: Double;
    private var _articleProgress: Double = 0;
    private var _articlesPublishedThisWeek: Int = 0;
    private var _articlesWrittenThisWeek: Int = 0;
    private var _daysEmployed: Int = 0; //Their salary raises every 15 days.
    private var _morale: Int = 500; //Lowers when no articles published for # of ticks, raises when published, lowers slowly every day
    private var _lastKnownGameDaysElapsed: Int = 0;
    private var _salary: Int;
//    private var _needsPromotion: Bool = false;
    
    //Morale Bonus Properties
    private var _paycheckCooldown = 0;
    
    //Constants
    private let PROGRESS_MAX: Double = Double(Simulation.TICKS_PER_DAY);
    fileprivate static let ARTICLE_RATE_MAX: Double = ((Double(Simulation.TICKS_PER_DAY) / 60) / 30) * 3; // 3 articles per day
    fileprivate static let ARTICLE_RATE_MIN: Double =  (Double(Simulation.TICKS_PER_DAY) / 60) / 30;      // 1:1 with the in-game day
    
    //Is the public interface for adding new pre-made Authors
    //in context of the currently employed authors
    init(exluding employedAuthors: inout [Author]) {
        let newAuthor = AuthorLibrary.getRandom(employedAuthors: &employedAuthors);
        _portrait = newAuthor.getPortrait();
        _name = newAuthor.getName();
        _experience = 0;
        _topics = newAuthor.getTopics();
        _quality = newAuthor.getQuality();
        _articleRate = newAuthor.getRate();
        _salary = newAuthor.getSalary();
    }
    
    //Handles the inits for the pre-made Authors with random stats
    //Used by AuthorLibrary
    fileprivate init(portrait: UIImage, name: String) {
        _portrait = portrait;
        _name = name;
        _experience = 0;
        _topics = TopicLibrary.getRandomTopics();
        _quality = AuthorLibrary.getRandomQuality();
        _articleRate = AuthorLibrary.getRandomRate();
        _salary = Int(_articleRate * 1000) + (_quality * 10);
    }
    
    //Public interface for custom author creation
    init(portrait: UIImage, name: String, topics: [Topic], quality: Int, articleRate: Double) {
        _portrait = portrait;
        _name = name;
        _experience = 0;
        _topics = topics;
        _quality = quality;
        _articleRate = articleRate;
        _salary = Int(_articleRate * 300);
    }
    
    func tick(elapsed days: Int) {
        reduceCooldowns();
        
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
    
    func getQuality() -> Int {
        return _quality;
    }
    
    func setNewQuality() {
        _quality += 1;
    }
    
    func getRate() -> Double {
        return _articleRate;
    }
    
    func setNewRate() {
        //Increases rate by a 10th of the difference between the min and max rates
        let rateIncrease: Double = (Author.ARTICLE_RATE_MAX - Author.ARTICLE_RATE_MIN) / 10.0;
        _articleRate = _articleRate + rateIncrease > Author.ARTICLE_RATE_MAX ? Author.ARTICLE_RATE_MAX : _articleRate + rateIncrease;
    }
    
    func getRateSymbol() -> String {
        let difference = Author.ARTICLE_RATE_MAX - Author.ARTICLE_RATE_MIN;
        
        if _articleRate < Author.ARTICLE_RATE_MIN + (difference * 0.25) {
            return "Very Slow";
        } else if _articleRate < Author.ARTICLE_RATE_MIN + (difference * 0.50) {
            return "Slow";
        } else if _articleRate < Author.ARTICLE_RATE_MIN + (difference * 0.75) {
            return "Fast";
        } else {
            return "Very Fast";
        }
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
        if _paycheckCooldown == 0 {
            if _morale < 80 {
                return "☠︎";
            } else if _morale <= 200 {
                return "☹︎-";
            } else if _morale <= 300 {
                return "☹︎";
            } else if _morale <= 500 {
                return "☺︎";
            } else if _morale <= 600 {
                return "☺︎+";
            } else if _morale <= 800 {
                return "☺︎++";
            } else {
                return "✪";
            }
        } else {
            return "$";
        }
    }
    
    func getMoraleColor() -> UIColor {
        return _paycheckCooldown == 0 ? (_morale <= 300 ? #colorLiteral(red: 0.8795482516, green: 0.1792428792, blue: 0.3018780947, alpha: 1) : #colorLiteral(red: 0, green: 0.4802635312, blue: 0.9984222054, alpha: 1)) : #colorLiteral(red: 0, green: 0.8052026629, blue: 0.3195570111, alpha: 1);
    }
    
    private func adjustMorale() {
        if _paycheckCooldown == 0 {
            if _daysEmployed > 7 {
                _morale -= 50;
                
                if _articlesPublishedThisWeek < 1 {
                    _morale -= 50;
                }
            } else if _daysEmployed > 30 {
                _morale -= 200;
            }
        }
    }
    
    func reduceCooldowns() {
        _paycheckCooldown -= _paycheckCooldown > 0 ? 1 : 0;
    }
    
    func getSalary() -> Int {
        return _salary;
    }
    
    func setNewSalary() {
        _salary = _articleRate == Author.ARTICLE_RATE_MAX ? _salary + (_quality * 10) : Int(_articleRate * 1000) + (_quality * 10);
    }
    
    func getCommission() -> Int {
        return getSalary() * 2;
    }
    
    func getPublishedThisWeek() -> Int {
        return _articlesPublishedThisWeek;
    }
    
    func publishArticle() {
        _articlesPublishedThisWeek += 1;
        increaseExperience(Double(_quality) * 10);
        _paycheckCooldown = Simulation.TICKS_PER_DAY / 12;
    }
    
    func getSubmittedThisWeek() -> Int {
        return _articlesWrittenThisWeek;
    }
    
    func submitArticle() {
        _articlesWrittenThisWeek += 1;
        _articleProgress = 0;
        increaseExperience(Double(_quality) * 2);
    }
    
    func getExperience() -> Double {
        return _experience;
    }
    
    func increaseExperience(_ exp: Double) {
        _morale += Int(exp * 0.25);
        _experience += exp;
    }
    
    func promoteIfNecessary() {
        if getSeniorityLevel() != _currentLevel {
            setNewQuality();
            setNewRate();
            setNewSalary();
            
            _currentLevel = getSeniorityLevel();
        }
    }
    
    func newArticleTopic() -> Topic {
        return _topics[Random(index: _topics.count)];
    }
}

class AuthorLibrary {
    private static let _AUTHORS: [Author] = [
        Author(portrait: #imageLiteral(resourceName: "Author7"), name: "Suzy Joe"),
        Author(portrait: #imageLiteral(resourceName: "Author9"), name: "Snazzy Jack Bricklayer"),
        Author(portrait: #imageLiteral(resourceName: "Author3"), name: "Frank Bottomwealth"),
        Author(portrait: #imageLiteral(resourceName: "Author5"), name: "Harold Knickers"),
        Author(portrait: #imageLiteral(resourceName: "Author6"), name: "Theresa Froshet"),
        Author(portrait: #imageLiteral(resourceName: "Author8"), name: "Lincoln Matherlips"),
        Author(portrait: #imageLiteral(resourceName: "Author1"), name: "Freddie Plicks"),
        Author(portrait: #imageLiteral(resourceName: "Author4"), name: "Wendy Mysten"),
        Author(portrait: #imageLiteral(resourceName: "Author2"), name: "Elaine Mendihooks"),
        Author(portrait: #imageLiteral(resourceName: "Author3"), name: "Chuck Vandel"),
        Author(portrait: #imageLiteral(resourceName: "Author8"), name: "Greg Heartis"),
        Author(portrait: #imageLiteral(resourceName: "Author1"), name: "Jesse Flickmaster"),
        Author(portrait: #imageLiteral(resourceName: "Author6"), name: "Nichole Tremble"),
        Author(portrait: #imageLiteral(resourceName: "Author5"), name: "Leonard Teaspray"),
        Author(portrait: #imageLiteral(resourceName: "Author4"), name: "Catherine Humble"),
        Author(portrait: #imageLiteral(resourceName: "Author9"), name: "Samuel Barth"),
        Author(portrait: #imageLiteral(resourceName: "Author7"), name: "Jackie Westerpile"),
        Author(portrait: #imageLiteral(resourceName: "Author3"), name: "Pete Underknuckle"),
        Author(portrait: #imageLiteral(resourceName: "Author1"), name: "Arthur Tinmonk"),
        Author(portrait: #imageLiteral(resourceName: "Author8"), name: "Richard Feak"),
        Author(portrait: #imageLiteral(resourceName: "Author5"), name: "Timothy Whiskerly"),
        Author(portrait: #imageLiteral(resourceName: "Author3"), name: "Matthew Snote"),
        Author(portrait: #imageLiteral(resourceName: "Author6"), name: "Brittany Blossoms"),
        Author(portrait: #imageLiteral(resourceName: "Author9"), name: "Nigel Tuntilly"),
        Author(portrait: #imageLiteral(resourceName: "Author1"), name: "James Heath"),
        Author(portrait: #imageLiteral(resourceName: "Author6"), name: "Meresa Plaingull"),
        Author(portrait: #imageLiteral(resourceName: "Author8"), name: "Norman Shugal"),
        Author(portrait: #imageLiteral(resourceName: "Author6"), name: "Lizzy Frankly"),
        Author(portrait: #imageLiteral(resourceName: "Author9"), name: "Les Beastline"),
        Author(portrait: #imageLiteral(resourceName: "Author4"), name: "Helga Harbinger"),
        Author(portrait: #imageLiteral(resourceName: "Author1"), name: "Chaz Gesture"),
        Author(portrait: #imageLiteral(resourceName: "Author1"), name: "Fletcher Klankapot"),
        Author(portrait: #imageLiteral(resourceName: "Author1"), name: "Nathan Zimpeck"),
        Author(portrait: #imageLiteral(resourceName: "Author8"), name: "Osmund Honeyfront"),
        Author(portrait: #imageLiteral(resourceName: "Author3"), name: "Terry Smackeral"),
        Author(portrait: #imageLiteral(resourceName: "Author5"), name: "Oliver Klipfin"),
        Author(portrait: #imageLiteral(resourceName: "Author4"), name: "Abbigail Mowrett"),
        Author(portrait: #imageLiteral(resourceName: "Author2"), name: "Jen Thistlebeak"),
        Author(portrait: #imageLiteral(resourceName: "Author5"), name: "Hank Prestal"),
        Author(portrait: #imageLiteral(resourceName: "Author1"), name: "Jerome Filks"),
        Author(portrait: #imageLiteral(resourceName: "Author8"), name: "Justin Hestile"),
        Author(portrait: #imageLiteral(resourceName: "Author6"), name: "Marie Gilphon"),
        Author(portrait: #imageLiteral(resourceName: "Author4"), name: "Emma Venbracket"),
        Author(portrait: #imageLiteral(resourceName: "Author6"), name: "Charlotte Klumph"),
        Author(portrait: #imageLiteral(resourceName: "Author7"), name: "Ava Estmire"),
        Author(portrait: #imageLiteral(resourceName: "Author9"), name: "Ike Crimmelflank"),
        Author(portrait: #imageLiteral(resourceName: "Author7"), name: "Kaylin Sprockets"),
        Author(portrait: #imageLiteral(resourceName: "Author7"), name: "Snutty Leftcut"),
        Author(portrait: #imageLiteral(resourceName: "Author7"), name: "Marcus Guildabreck"),
        Author(portrait: #imageLiteral(resourceName: "Author5"), name: "Bill Festerville")
    ];
    
    var blank: Author = Author(portrait: UIImage(), name: "blank", topics: [], quality: 0, articleRate: 0);
    
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
    
    static func getRandomQuality() -> Int {
        return Random(int: 1 ... 5);
    }
    
    static func getRandomRate() -> Double {
        return Random(double: Author.ARTICLE_RATE_MIN ... Author.ARTICLE_RATE_MAX);
    }
}

