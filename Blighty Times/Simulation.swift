//
//  GameService.swift
//  BlightyTimes
//
//  Created by Zachary Duncan on 8/27/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import Foundation

class Simulation {
    //Company
    let company: Company = Company();
    
    //Author properties
    private var _employedAuthors: [Author] = [];
    var employedAuthors: [Author] { return _employedAuthors; }
    private var _applicantAuthors: [Author] = [];
    var applicantAuthors: [Author] { return _applicantAuthors; }
    
    //Article Properties
    private var _newArticles: [Article] = [];
    var newArticles: [Article] { return _newArticles; }
    private var _writtenArticles: [Article] = Array(repeating: ArticleLibrary.blank, count: 12);
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
    private let _MAX_PAUSES: Int = 5;
    private var _playerPausesLeft: Int = 5; //Fewer pauses for higher player level
    
    //Game Constants
    static let TICK_RATE: TimeInterval = 0.1;
    static let TICKS_PER_DAY: Int = 100;
    
    
    @objc func tick() {
        _gameTimeElapsed += 1;
        
        writtenArticleTick();
        authorTick();
        
        if isEndOfDay() {
            publishNextEdition();
            company.tick(subscribers: 1000, employedAuthors: _employedAuthors);
            nextDay();
            chanceToSpawnApplicant();
        }
    }
    
    func publishNextEdition() {
        for i in 0 ..< _nextEditionArticles.count {
            if _nextEditionArticles[i] !== ArticleLibrary.blank {
                _nextEditionArticles[i].publish();
                company.payCommission(to: _nextEditionArticles[i].getAuthor());
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
        
        print("_writtenArticles.count = \(_writtenArticles.count)");
    }
    
    func authorTick() {
        var i = _employedAuthors.count - 1;
        for _ in 0 ..< _employedAuthors.count {
            _employedAuthors[i].tick(elapsed: _gameDaysElapsed);
            
            if _employedAuthors[i].hasFinishedArticle() && _writtenArticles.count + _newArticles.count < 12 {
                _employedAuthors[i].submitArticle();
                
                _newArticles.append(Article(topic: _employedAuthors[i].newArticleTopic(), author: &_employedAuthors[i]))
            }
            
            if _employedAuthors[i].getMorale() < 1 {
                quit(_employedAuthors[i]);
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
    
    func chanceToSpawnApplicant() {
        if Random(int: 0 ... 10) == 1 {
            spawnApplicant();
            hire(_applicantAuthors[0]);
        }
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
        while !_newArticles.isEmpty {
            _writtenArticles.append(_newArticles.first!);
            _newArticles.removeFirst();
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
        print("Pause status: \(_gameIsPaused)");
        return _gameIsPaused;
    }
    
    func pauseplayButtonPressed() {
        if _playerPausesLeft == 0 {
            if _gameIsPaused {
                _gameIsPaused = false;
            }
        } else if _playerPausesLeft > 0 {
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
