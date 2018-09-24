//
//  GameService.swift
//  BlightyTimes
//
//  Created by Zachary Duncan on 8/27/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import Foundation

class Simulation {
    //Author properties
    private var _employedAuthors: [Author] = [];
    var employedAuthors: [Author] { return _employedAuthors; }
    private var _applicantAuthors: [Author] = [];
    var applicantAuthors: [Author] { return _applicantAuthors; }
    
    //Article Properties
    private var _newArticles: [Article] = [];
    var newArticles: [Article] { return _newArticles; }
    private var _writtenArticles: [Article] = [];
    var writtenArticles: [Article] { return _writtenArticles; }
    private var _nextEditionArticles: [Article] = Array(repeating: ArticleLibrary.blank, count: 6);
    var nextEditionArticles: [Article] { return _nextEditionArticles; }
    private var _publishedTopicHistory: [Topic] = [];
    var publishedTopicHistory: [Topic] { return _publishedTopicHistory; }
    
    //Time properties
    private var _gameTimeElapsed: Int = 0;
    private var _gameDaysElapsed: Int { return _gameTimeElapsed / Simulation.TICKS_PER_DAY; }
    private var _gameDayOfTheWeek: Int = 1;
    private var _gameIsPaused: Bool = false;
    
    //Player properties
    private var _playerXP: Int = 0;
    private var _playerPausesLeft: Int = 5; //Fewer pauses for higher player level
    private var _playerLevel: Int = 1;
    
    //Game Constants
    static let TICK_RATE: TimeInterval = 0.3;
    static let TICKS_PER_DAY: Int = 24;
    
    
    @objc func tick() {
        _gameTimeElapsed += 1;
        
        if Int.random(in: 0...50) == 5 {
            spawnApplicant();
            hire(_applicantAuthors[0]);
        }
        
        writtenArticleTick();
        authorTick();
        
        if isEndOfDay() {
            publishNextEdition();
            nextDay();
        }
    }
    
    func publishNextEdition() {
        for i in 0 ..< _nextEditionArticles.count {
            if _nextEditionArticles[i] !== ArticleLibrary.blank {
                _nextEditionArticles[i].publish();
                _publishedTopicHistory.append(_nextEditionArticles[i].getTopic());
                _nextEditionArticles[i] = ArticleLibrary.blank;
            }
        }
    }
    
    func writtenArticleTick() {
        var i = _writtenArticles.count - 1;
        for _ in 0 ..< _writtenArticles.count{
            _writtenArticles[i].tick();
            
            if _writtenArticles[i].isInNextEdition() {
                assignToNextEdition(article: &_writtenArticles[i]);
            } else {
                if _writtenArticles[i].getLifetime() <= 0 {
                    _writtenArticles.remove(at: i);
                }
            }
            
            i -= 1;
        }
    }
    
    func authorTick() {
        var i = _employedAuthors.count - 1;
        for _ in 0 ..< _employedAuthors.count {
            _employedAuthors[i].tick(elapsed: _gameDaysElapsed);
            
            if _employedAuthors[i].getMorale() < 1 {
                quit(_employedAuthors[i]);
            }
            
            if _employedAuthors[i].hasFinishedArticle() {
                _employedAuthors[i].submitArticle();
                
                let topic = TopicLibrary.getRandomTopics(from: _employedAuthors[i].getTopics(), quantity: 1)[0];
                _newArticles.append(Article(topic: topic, author: &_employedAuthors[i]))
            }
            
            i -= 1;
        }
    }
    
    
    //Author Methods
    func hire(_ author: Author) {
        _employedAuthors.append(author);
        
        for i in 0 ..< _applicantAuthors.count {
            if _applicantAuthors[i].getName() == author.getName() {
                _applicantAuthors.remove(at: i);
            }
        }
    }
    
    func fire(_ author: Author) {
        var i: Int = 0;
        for _ in 0 ..< _employedAuthors.count {
            if _employedAuthors[i].getName() == author.getName() {
                _employedAuthors.remove(at: i);
                i -= 1;
            }
            i += 1;
        }
    }
    
    func quit(_ author: Author) {
        print(author.getName() + " quit");
        fire(author);
    }
    
    func spawnApplicant() {
        _applicantAuthors.append(Author(exluding: &_employedAuthors));
    }
    
    func spawnFirstAuthor() {
        spawnApplicant();
        hire(_applicantAuthors[0]);
    }
    
    func assignToNextEdition(article: inout Article) {
        NELoop: for i in 0 ..< _nextEditionArticles.count {
            if _nextEditionArticles[i] === ArticleLibrary.blank {
                _nextEditionArticles[i] = article;
                break NELoop;
            }
        }
    }
    
    
    //Article Methods
    func addToNextEdition(article: inout Article, index: Int) {
        if _nextEditionArticles[index].getTopic().getName() == "blank" {
            _nextEditionArticles[index] = article;
        }
    }
    
    func syncNewArticles() {
        for i in 0 ..< _newArticles.count {
            _writtenArticles.append(_newArticles[i]);
        }
    }
    
    
    //Time Methods
    private func isEndOfDay() -> Bool {
        return _gameTimeElapsed % Simulation.TICKS_PER_DAY == 0;
    }
    
    private func nextDay() {
        if _gameDayOfTheWeek == 7 {
            _gameDayOfTheWeek = 1;
        } else {
            _gameDayOfTheWeek += 1;
        }
    }
    
    func getDayOfTheWeek() -> String {
        switch _gameDayOfTheWeek {
        case 1:
            return "Monday";
        case 2:
            return "Tuesday";
        case 3:
            return "Wednesday";
        case 4:
            return "Thursday";
        case 5:
            return "Friday";
        case 6:
            return "Saturday";
        case 7:
            return "Sunday";
        default:
            return "Error";
        }
    }
    
    func isPaused() -> Bool {
        return _gameIsPaused;
    }
    
    func pauseplayButtonPressed() {
        if _playerPausesLeft > 0 {
            if _gameIsPaused {
                _gameIsPaused = false;
            } else {
                _gameIsPaused = true;
                _playerPausesLeft -= 1;
            }
        }
    }
    
    func getPausesLeft() -> Int {
        return _playerPausesLeft;
    }
}
