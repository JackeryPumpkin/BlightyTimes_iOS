//
//  GameService.swift
//  BlightyTimes
//
//  Created by Zachary Duncan on 8/27/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import UIKit

class Simulation {
    //Company
    let company: Company = Company();
    
    //Author properties
    private var _employedAuthors: [Author] = [];
    var employedAuthors: [Author] { return _employedAuthors; }
    private var _applicantAuthors: [Author] = [];
    var applicantAuthors: [Author] { return _applicantAuthors; }
    
    //Article Properties
    var newArticles: [Article] = [];
//    var newArticles: [Article] { return newArticles; }
    private var _writtenArticles: [Article] = [];
    var writtenArticles: [Article] { return _writtenArticles; }
    private var _nextEditionArticles: [Article] = Array(repeating: ArticleLibrary.blank, count: 6);
    var nextEditionArticles: [Article] { return _nextEditionArticles; }
    private var _publishedTopicHistory: [Topic] = [];
    var publishedTopicHistory: [Topic] { return _publishedTopicHistory; }
    
    //Time properties
    private var _gameTimeElapsed: Int = 60;
    private var _gameDaysElapsed: Int { return _gameTimeElapsed / Simulation.TICKS_PER_DAY; }
    private var _gameDayOfTheWeek: Int = 1;
//    private let _GAME_MINUTE: Double = Double(Simulation.TICKS_PER_DAY / 24 / 60);
    private let _TICKS_PER_HOUR: Int = Simulation.TICKS_PER_DAY / 24;
//    private var _gameDayMinutesElapsed: Int = 60;
    private var _gameDayHoursElapsed: Int = 1;
    private var _gameIsPaused: Bool = false;
    
    //Player properties
    private let _MAX_PAUSES: Int = 5;
    private var _playerPausesLeft: Int = 5; //Fewer pauses for higher player level
    
    //Game Constants
    static let TICK_RATE: TimeInterval = 0.03;
    static let TICKS_PER_DAY: Int = 1800;
    
    
    @objc func tick() {
        moveTimeForward();
        
        writtenArticleTick();
        authorTick();
        
        if isEndOfDay() {
            publishNextEdition();
            company.tick(subscribers: 1000, employedAuthors: _employedAuthors);
            nextDay();
            chanceToSpawnApplicant();
        }
    }
    
    func start() {
        spawnFirstAuthor();
        spawnFirstAuthor();
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
    }
    
    func authorTick() {
        var i = _employedAuthors.count - 1;
        for _ in 0 ..< _employedAuthors.count {
            _employedAuthors[i].tick(elapsed: _gameDaysElapsed);
            
            if _employedAuthors[i].hasFinishedArticle() && _writtenArticles.count + newArticles.count < 12 {
                _employedAuthors[i].submitArticle();
                
                newArticles.append(Article(topic: _employedAuthors[i].newArticleTopic(), author: &_employedAuthors[i]))
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
        
        hireLoop: for i in 0 ..< _applicantAuthors.count {
            if _applicantAuthors[i].getName() == author.getName() {
                _applicantAuthors.remove(at: i);
                break hireLoop;
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
        var auths = _employedAuthors + _applicantAuthors
        _applicantAuthors.append(Author(exluding: &auths));
    }
    
    func spawnFirstAuthor() {
        spawnApplicant();
        hire(_applicantAuthors[0]);
    }
    
    func chanceToSpawnApplicant() -> Bool {
        var spawned = false;
        if Random(int: 0 ... 0) == 0 {
            spawnApplicant();
            spawned = true;
        }
        return spawned;
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
            removeFromPending(article: article);
        }
    }
    
    func removeFromPending(article: Article) {
        for i in 0 ..< _writtenArticles.count {
            if _writtenArticles[i] === article {
                _writtenArticles.remove(at: i);
            }
        }
    }
    
    func syncNewArticles() {
        while !newArticles.isEmpty {
            _writtenArticles.append(newArticles.first!);
            newArticles.removeFirst();
        }
    }
    
    
    //Time Methods
    private func moveTimeForward() {
        _gameTimeElapsed += 1;
        
        if _gameTimeElapsed % _TICKS_PER_HOUR == 0 {
            _gameDayHoursElapsed = _gameDayHoursElapsed > 23 ? 1 : _gameDayHoursElapsed + 1;
        }
        
        //// This setup is for tracking time by minutes
        //if _gameTimeElapsed % _TICKS_PER_HOUR == 0 {
        //    _gameDayMinutesElapsed = _gameDayMinutesElapsed > 1500 ? 60 : _gameDayMinutesElapsed + 1;
        //}
    }
    
    func getPlayheadLength(maxLength: CGFloat) -> CGFloat {
        if _gameTimeElapsed == 0 {
            return CGFloat(0);
        } else {
            return maxLength * ((CGFloat(_gameTimeElapsed) - CGFloat(Simulation.TICKS_PER_DAY * _gameDaysElapsed)) / CGFloat(Simulation.TICKS_PER_DAY));
        }
    }
    
    func getDaysElapsed() -> Int {
        return _gameDaysElapsed;
    }
    
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
    
    func getTimeOfDay() -> String {
        var time: String = "12:00 AM";
        
        if _gameDayHoursElapsed <= 12 {
            if _gameDayHoursElapsed == 1 {
                time = "\(12) AM";
            } else {
                time = "\(_gameDayHoursElapsed - 1) AM";
            }
        } else {
            if _gameDayHoursElapsed == 13 {
                time = "\(12) PM";
            } else {
                time = "\(_gameDayHoursElapsed - 13) PM";
            }
        }
        
        //// This setup is for tracking time by minutes
        //        for hour in 1 ... 24 {
        //            if _gameDayMinutesElapsed / 60 == hour {
        //                let minute: Int = _gameDayMinutesElapsed % 60 < 10 ? _gameDayMinutesElapsed % 60 : _gameDayMinutesElapsed % 60;
        //
        //                if _gameDayMinutesElapsed <= 780 {
        //                    if hour == 1 {
        //                        time = "\(12):\(minute) AM";
        //                    } else {
        //                        time = "\(hour - 1):\(minute) AM";
        //                    }
        //                } else {
        //                    if hour == 13 {
        //                        time = "\(12):\(minute) PM";
        //                    } else {
        //                        time = "\(hour - 13):\(minute) PM";
        //                    }
        //                }
        //            }
        //        }
        
        return time;
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
