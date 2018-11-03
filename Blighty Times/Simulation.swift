//
//  GameService.swift
//  BlightyTimes
//
//  Created by Zachary Duncan on 8/27/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import UIKit

class Simulation {
    let COMPANY: Company = Company();
    let POPULATION: Population = Population();
    
    //Author properties
    private var _employedAuthors: [Author] = [];
            var employedAuthors: [Author] { return _employedAuthors; }
    private var _applicantAuthors: [Author] = [];
            var applicantAuthors: [Author] { return _applicantAuthors; }
    
    //Article Properties
            var newArticles: [Article] = [];
            //var newArticles: [Article] { return newArticles; }
    private var _writtenArticles: [Article] = [];
            var writtenArticles: [Article] { return _writtenArticles; }
     var _nextEditionArticles: [Article] = Array(repeating: ArticleLibrary.blank, count: 6);
    //var nextEditionArticles: [Article] { return _nextEditionArticles; }
    private var _publishedTopicHistory: [Topic] = [];
            var publishedTopicHistory: [Topic] { return _publishedTopicHistory; }
    
    //Time properties
    private var _ticksElapsed: Int = 60;
    private var _gameDaysElapsed: Int { return _ticksElapsed / Simulation.TICKS_PER_DAY; }
    private var _gameDayOfTheWeek: Int = 1;
    //private let _GAME_MINUTE: Double = Double(Simulation.TICKS_PER_DAY / 24 / 60);
    private let _TICKS_PER_HOUR: Int = Simulation.TICKS_PER_DAY / 24;
    //private var _gameDayMinutesElapsed: Int = 60;
    private var _gameDayHoursElapsed: Int = 1;
    private var _gameIsPaused: Bool = false;
    
    //Weekly Properties
    private var _employeesHiredThisWeek: Int = 0;
    private var _employeesFiredThisWeek: Int = 0;
    private var _promotionsGivenThisWeek: Int = 0;
    private var _articlesPublishedThisWeek: Int = 0;
    private var _averageQualityThisWeek: Int = 0;
    
    //Player properties
    private let _MAX_PAUSES: Int = 7;
    private var _playerPausesLeft: Int = 7;
    
    //Game Constants
    static let TICK_RATE: TimeInterval = 0.03;
    static let TICKS_PER_DAY: Int = 1800;
    
    private var NE_releasedEarly: Bool = false;
    
    
    @objc func tick() {
        moveTimeForward();
        chanceToSpawnApplicant();
        writtenArticleTick();
        nextEditionArticleTick();
        authorTick();
        applicantTick();
        
        if isEndOfDay() {
            if !NE_releasedEarly {
                publishNextEdition(is: false);
            }
            NE_releasedEarly = false;
            nextDay();
        }
    }
    
    func start() {
        spawnFirstAuthor();
        spawnFirstAuthor();
        spawnApplicant();
        
        for i in 0 ..< _employedAuthors.count {
            newArticles.append(Article(topic: _employedAuthors[i].newArticleTopic(), author: &_employedAuthors[i]));
            newArticles.append(Article(topic: _employedAuthors[i].newArticleTopic(), author: &_employedAuthors[i]));
        }
    }
    
    func publishNextEdition(is early: Bool) {
        POPULATION.tick(published: _nextEditionArticles, is: early);
        NE_releasedEarly = early;
        
        for i in 0 ..< _nextEditionArticles.count {
            if _nextEditionArticles[i] !== ArticleLibrary.blank {
                _nextEditionArticles[i].publish();
                COMPANY.payCommission(to: _nextEditionArticles[i].getAuthor());
                _publishedTopicHistory.append(_nextEditionArticles[i].getTopic());
                _nextEditionArticles[i] = ArticleLibrary.blank;
                _articlesPublishedThisWeek += 1;
            }
        }
        if early { forceNextDay(); }
    }
    
    private func writtenArticleTick() {
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
    
    private func nextEditionArticleTick() {
        var i = _nextEditionArticles.count - 1;
        for _ in 0 ..< _nextEditionArticles.count {
            _nextEditionArticles[i].tick();
            
            if _nextEditionArticles[i].getLifetime() <= 0 {
                _nextEditionArticles[i] = ArticleLibrary.blank;
            }
            
            i -= 1;
        }
    }
    
    private func authorTick() {
        var i = _employedAuthors.count - 1;
        for _ in 0 ..< _employedAuthors.count {
            _employedAuthors[i].employedTick(elapsed: _gameDaysElapsed);
            
            if _employedAuthors[i].hasFinishedArticle() && _writtenArticles.count + newArticles.count < 12 {
                _employedAuthors[i].submitArticle();
                
                newArticles.append(Article(topic: _employedAuthors[i].newArticleTopic(), author: &_employedAuthors[i]));
            }
            
            if _employedAuthors[i].getMorale() < 1 {
                quit(_employedAuthors[i]);
            }
            
            i -= 1;
        }
    }
    
    private func applicantTick() {
        var i = _applicantAuthors.count - 1;
        for _ in 0 ..< _applicantAuthors.count {
            _applicantAuthors[i].applicantTick(elapsed: _gameDaysElapsed);
            
            if _applicantAuthors[i].getMorale() < 1 {
                withdraw(applicantIndex: i);
            }
            
            i -= 1;
        }
    }
    
    func weeklyReset() {
        _employeesHiredThisWeek = 0;
        _employeesFiredThisWeek = 0;
        _promotionsGivenThisWeek = 0;
        _articlesPublishedThisWeek = 0;
        _averageQualityThisWeek = 0;
        
        for author in _employedAuthors {
            author.weeklyReset();
        }
    }
    
    
    //Author Methods
    func hire(_ author: Author) {
        author.becomeHired();
        _employedAuthors.append(author);
        
        hireLoop: for i in 0 ..< _applicantAuthors.count {
            if _applicantAuthors[i].getName() == author.getName() {
                _applicantAuthors.remove(at: i);
                break hireLoop;
            }
        }
        
        _employeesHiredThisWeek += 1;
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
        
        _employeesFiredThisWeek += 1;
    }
    
    func quit(_ author: Author) {
        fire(author);
        _employeesFiredThisWeek -= 1; //Neutralizes the increase in fire()
    }
    
    func withdraw(applicantIndex i: Int) {
        _applicantAuthors.remove(at: i);
    }
    
    func spawnApplicant() {
        var auths = _employedAuthors + _applicantAuthors
        _applicantAuthors.append(Author(exluding: &auths));
    }
    
    func spawnFirstAuthor() {
        spawnApplicant();
        hire(_applicantAuthors[0]);
    }
    
    func spawnTestAuthor() {
        _employedAuthors.append(Author(portrait: UIImage(), name: "Test", topics: [TopicLibrary.list[0]], quality: 5, articleRate: ((Double(Simulation.TICKS_PER_DAY) / 60) / 30) * 3))
    }
    
    func chanceToSpawnApplicant() {
        if _ticksElapsed % 200 == 0 {
            if Random(int: 1 ... 5) == 5 {
                spawnApplicant();
            }
        }
    }
    
    func getEmployeesHiredThisWeek() -> Int {
        return _employeesHiredThisWeek;
    }
    
    func getEmployeesFiredThisWeek() -> Int {
        return _employeesFiredThisWeek;
    }
    
    func getPromotionsGivenThisWeek() -> Int {
        for author in _employedAuthors {
            _promotionsGivenThisWeek += author.getPromotionsThisWeek();
        }
        
        return _promotionsGivenThisWeek;
    }
    
    private func assignToNextEdition(article: inout Article) {
        NELoop: for i in 0 ..< _nextEditionArticles.count {
            if _nextEditionArticles[i] === ArticleLibrary.blank {
                _nextEditionArticles[i] = article;
                break NELoop;
            }
        }
    }
    
    
    //Article Methods
    func addToNextEdition(article: inout Article, index: Int) -> Bool {
        var didAdd = false;
        
        if _nextEditionArticles[index] === ArticleLibrary.blank {
            _nextEditionArticles[index] = article;
            removeFromPending(article: article);
            
            didAdd = true;
        }
        
        return didAdd;
    }
    
    func changeIndexNextEdition(from pos1: Int, to pos2: Int) -> Bool {
        var didSwitch = false;
        
        if _nextEditionArticles[pos2] === ArticleLibrary.blank {
            _nextEditionArticles[pos2] = _nextEditionArticles[pos1];
            _nextEditionArticles[pos1] = ArticleLibrary.blank;
            
            didSwitch = true;
        }
        
        return didSwitch;
    }
    
    func backToPending(ne_index: Int) -> Bool {
        var didPend = false;
        
        if _writtenArticles.count < 12 {
            _writtenArticles.append(_nextEditionArticles[ne_index]);
            _nextEditionArticles[ne_index] = ArticleLibrary.blank;
            
            didPend = true;
        }
        
        return didPend;
    }
    
    func removeFromPending(article: Article) {
        remloop: for i in 0 ..< _writtenArticles.count {
            if _writtenArticles[i] === article {
                _writtenArticles.remove(at: i);
                
                break remloop;
            }
        }
    }
    
    func syncNewArticles() {
        while !newArticles.isEmpty {
            _writtenArticles.append(newArticles.first!);
            newArticles.removeFirst();
        }
    }
    
    func getArticlesPublishedThisWeek() -> Int {
        return _articlesPublishedThisWeek;
    }
    
    func getAverageQualityThisWeek() -> Int {
        return _averageQualityThisWeek;
    }
    
    
    //Time Methods
    private func moveTimeForward() {
        _ticksElapsed += 1;
        
        if _ticksElapsed % _TICKS_PER_HOUR == 0 {
            _gameDayHoursElapsed = _gameDayHoursElapsed > 23 ? 1 : _gameDayHoursElapsed + 1;
        }
        
        //// This setup is for tracking time by minutes
        //if _gameTimeElapsed % _TICKS_PER_HOUR == 0 {
        //    _gameDayMinutesElapsed = _gameDayMinutesElapsed > 1500 ? 60 : _gameDayMinutesElapsed + 1;
        //}
    }
    
    func forceNextDay() {
        let timeDelta = Simulation.TICKS_PER_DAY - (_ticksElapsed % Simulation.TICKS_PER_DAY);
        
        for _ in 1 ... timeDelta {
//            moveTimeForward();
            tick();
        }
        
//        nextDay();
    }
    
    func getPlayheadLength(maxLength: CGFloat) -> CGFloat {
        if _ticksElapsed == 0 {
            return CGFloat(0);
        } else {
            return maxLength * ((CGFloat(_ticksElapsed) - CGFloat(Simulation.TICKS_PER_DAY * _gameDaysElapsed)) / CGFloat(Simulation.TICKS_PER_DAY));
        }
    }
    
    func getDaysElapsed() -> Int {
        return _gameDaysElapsed;
    }
    
    func isEndOfDay() -> Bool {
        return _ticksElapsed % Simulation.TICKS_PER_DAY == 0;
    }
    
    func isEndOfWeek() -> Bool {
        return _ticksElapsed % (Simulation.TICKS_PER_DAY * 7) == 0;
    }
    
    private func nextDay() {
        if _gameDayOfTheWeek == 7 {
            _gameDayOfTheWeek = 1;
        } else {
            _gameDayOfTheWeek += 1;
        }
        
        COMPANY.tick(subscribers: POPULATION.getTotalSubscriberCount(), employedAuthors: _employedAuthors);
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
    
    func getWeekNumber() -> Int {
        return _gameDaysElapsed > 0 ? _gameDaysElapsed / 7 : 0;
    }
    
    func isPaused() -> Bool {
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
    
    
    //Population Methods
    func getRegionGraphLengths(with barLength: CGFloat) -> [CGFloat] {
        var lengths: [CGFloat] = []
        
        for region in POPULATION.regions {
            if region.getTotalSubscriberCount() == 0 {
                lengths.append(CGFloat(0));
            } else {
                lengths.append(barLength * ((CGFloat(region.getTotalSubscriberCount()) / CGFloat(region.getSize()))));
            }
        }
        
        return lengths;
    }
}
