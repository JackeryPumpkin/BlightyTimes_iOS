//
//  GameService.swift
//  BlightyTimes
//
//  Created by Zachary Duncan on 8/27/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import UIKit

class Simulation {
    private var _company: Company = Company();
    var company: Company { return _company }
    
    private var _population: Population = Population();
    var population: Population { return _population }
    
    private var _office: Office = Office.small()
    var office: Office { return _office }
    private var _officeList: [Office] = [.small(), .medium(), .large(), .huge()]
    var officeList: [Office] { return _officeList }
    
    var eventList: [Event] = [];
    
    //Author properties
    private var _employedAuthors: [Author] = [];
    var employedAuthors: [Author] { return _employedAuthors; }
    
    private var _applicantAuthors: [Author] = [];
    var applicantAuthors: [Author] { return _applicantAuthors; }
    
    //Article Properties
    private var NE_releasedEarly: Bool = false;
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
    
    //Weekly Properties
    private var _employeesHiredThisWeek: Int = 0;
    private var _employeesFiredThisWeek: Int = 0;
    private var _promotionsGivenThisWeek: Int = 0;
    private var _articlesPublishedThisWeek: Int = 0;
    private var _articleQualitiesThisWeek: [Int] = [];
    
    //Player properties
    static private let _MAX_PAUSES: Int = 7;
    private var _playerPausesLeft: Int = Simulation._MAX_PAUSES;
    
    //Game Constants
    static let TICK_RATE: TimeInterval = 0.03;
    static let TICKS_PER_DAY: Int = 1800;
    
    var gameMode: GameMode!
    
    
    @objc func tick() {
        moveTimeForward();
        chanceToSpawnApplicant();
        writtenArticleTick();
        nextEditionArticleTick();
        employeeTick();
        applicantTick();
        eventTick();
        
        if isEndOfDay() {
            if !NE_releasedEarly {
                publishNextEdition(early: false);
            }
            
            NE_releasedEarly = false;
            nextDay();
            chanceToSpawnNewsEvent();
            population.spreadNews(getCurrentNewsEventTopic());
        }
    }
    
    func start() {
        switch gameMode! {
        case .small:
            smallStart()
        case .medium:
            mediumStart()
        case .large:
            largeStart()
        case .huge:
            hugeStart()
        default:
            randomStart()
        }
    }
    
    private func smallStart() {
        _company = Company(startingFunds: 500000)
        _ = purchaseOffice(.small, starting: true)
        _population = Population(from: _office.size)
        
        spawnStartingAuthor()
        spawnApplicant()
        
        for i in 0 ..< _employedAuthors.count {
            newArticles.append(Article(topic: _employedAuthors[i].newArticleTopic(), author: &_employedAuthors[i]))
        }
    }
    
    private func mediumStart() {
        _company = Company(startingFunds: 10000)
        _ = purchaseOffice(.medium, starting: true)
        _population = Population(from: _office.size)
        
        spawnStartingAuthor()
        spawnStartingAuthor()
        spawnApplicant()
        
        for i in 0 ..< _employedAuthors.count {
            newArticles.append(Article(topic: _employedAuthors[i].newArticleTopic(), author: &_employedAuthors[i]))
            newArticles.append(Article(topic: _employedAuthors[i].newArticleTopic(), author: &_employedAuthors[i]))
        }
    }
    
    private func largeStart() {
        _company = Company(startingFunds: 20000)
        _ = purchaseOffice(.large, starting: true)
        _population = Population(from: _office.size)
        
        spawnStartingAuthor()
        spawnStartingAuthor()
        spawnStartingAuthor()
        spawnApplicant()
        
        for i in 0 ..< _employedAuthors.count {
            newArticles.append(Article(topic: _employedAuthors[i].newArticleTopic(), author: &_employedAuthors[i]))
            newArticles.append(Article(topic: _employedAuthors[i].newArticleTopic(), author: &_employedAuthors[i]))
            newArticles.append(Article(topic: _employedAuthors[i].newArticleTopic(), author: &_employedAuthors[i]))
        }
    }
    
    private func hugeStart() {
        _company = Company(startingFunds: 50000)
        _ = purchaseOffice(.huge, starting: true)
        _population = Population(from: _office.size)
        
        spawnStartingAuthor()
        spawnStartingAuthor()
        spawnStartingAuthor()
        spawnStartingAuthor()
        spawnApplicant()
        
        for i in 0 ..< _employedAuthors.count {
            newArticles.append(Article(topic: _employedAuthors[i].newArticleTopic(), author: &_employedAuthors[i]))
            newArticles.append(Article(topic: _employedAuthors[i].newArticleTopic(), author: &_employedAuthors[i]))
            newArticles.append(Article(topic: _employedAuthors[i].newArticleTopic(), author: &_employedAuthors[i]))
        }
    }
    
    private func randomStart() {
        let randOfficeSize = OfficeSize(rawValue: Int.random(in: 0 ..< OfficeSize.allCases.count)) ?? .small
        switch randOfficeSize {
        case .small:
            smallStart()
        case .medium:
            mediumStart()
        case .large:
            largeStart()
        case .huge:
            hugeStart()
        }
    }
    
    func publishNextEdition(early: Bool) {
        population.tick(published: _nextEditionArticles, is: early);
        NE_releasedEarly = early;
        
        for i in 0 ..< _nextEditionArticles.count {
            if _nextEditionArticles[i] !== ArticleLibrary.blank {
                //Adjusts author stats and company funds
                _nextEditionArticles[i].publish();
                company.payCommission(to: _nextEditionArticles[i].getAuthor());
                
                //Tracks stats for end-of-week score card
                _articlesPublishedThisWeek += 1;
                _articleQualitiesThisWeek.append(_nextEditionArticles[i].getQuality());
                
                //Adds the current topic to your history to be shown in an infograph
                //then resets the article to .blank
                _publishedTopicHistory.append(_nextEditionArticles[i].getTopic());
                _nextEditionArticles[i] = ArticleLibrary.blank;
            }
        }
        
        //This happens at the botton to ensure that early published
        //articles don't time-out before being published
        if early { forceNextDay(); }
    }
    
    func companyTick() {
        company.tick(subscribers: population.getTotalSubscriberCount(), employedAuthors: _employedAuthors, officeDailyCosts: _office.dailyCosts)
        
        var committedCash: Int = 0
        
        for author in _employedAuthors {
            committedCash += author.getSalary()
        }
        
        committedCash += company.getOperationsCosts()
        committedCash += _office.dailyCosts
        
        if committedCash > company.getFunds() {
            add(CompanyEvent(title: "Low Funds", message: "Your company's funds are getting critically low. You'll need to capture new subscribers or make cuts to your workforce.", color: Event.veryBadColor, image: _office.image))
        }
        
        //Check for win-case
        
        //Check for lose-case
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
            if _nextEditionArticles[i] === ArticleLibrary.blank {
                if _nextEditionArticles[i].getLifetime() <= 0 {
                    _nextEditionArticles[i] = ArticleLibrary.blank;
                } else {
                    _nextEditionArticles[i].tick()
                }
            }
            
            i -= 1;
        }
    }
    
    private func employeeTick() {
        var i = _employedAuthors.count - 1;
        
        //Checks the employed authors backwards so that low-morale authors
        //can quit and not put the index out of bounds
        for _ in 0 ..< _employedAuthors.count {
            _employedAuthors[i].employedTick(elapsed: _gameDaysElapsed, moraleModifier: _office.moraleModifier);
            var event: Event?
            
            //This chunk checks for various author events
            if _employedAuthors[i].hasCriticalMorale {
                event = EmployeeEvent(title: "Low Morale",
                                      message: _employedAuthors[i].getName() + "'s morale is getting critically low.",
                                      color: Event.veryBadColor,
                                      image: _employedAuthors[i].getPortrait())
                
                _employedAuthors[i].hasCriticalMorale = false;
            }
            else if _employedAuthors[i].hasInfrequentPublished {
                event = EmployeeEvent(title: "Feeling Aimless",
                                      message: _employedAuthors[i].getName() + " is annoyed that their articles haven't been published recently.",
                                      color: Event.badColor,
                                      image: _employedAuthors[i].getPortrait())
                
                _employedAuthors[i].hasInfrequentPublished = false;
            }
            else if _employedAuthors[i].hasPromotionAnxiety {
                event = EmployeeEvent(title: "Feeling Underappreciated",
                                      message: _employedAuthors[i].getName() + " is upset that they haven't gotten a promotion for their hard work.",
                                      color: Event.badColor,
                                      image: _employedAuthors[i].getPortrait())
                
                _employedAuthors[i].hasPromotionAnxiety = false;
            }
            else if _employedAuthors[i].hasPendingPromotion {
                event = EmployeeEvent(title: "Level Up!",
                                      message: _employedAuthors[i].getName() + " has been grinding long hours and is now up for a promotion.",
                                      color: Event.goodColor,
                                      image: _employedAuthors[i].getPortrait())
                
                _employedAuthors[i].hasPendingPromotion = false;
            }
            
            if let event = event {
                add(event)
            }
            
            if _employedAuthors[i].hasFinishedArticle() && _writtenArticles.count + newArticles.count < 12 {
                _employedAuthors[i].submitArticle();
                
                newArticles.append(Article(topic: _employedAuthors[i].newArticleTopic(), author: &_employedAuthors[i]));
            }
            
            if _employedAuthors[i].getMorale() < 1 {
                quit(authorAt: i);
            }
            
            i -= 1;
        }
    }
    
    private func applicantTick() {
        var i = _applicantAuthors.count - 1;
        
        //Checks the applicant authors backwards so that low-morale authors
        //can withdraw and not put the index out of bounds
        for _ in 0 ..< _applicantAuthors.count {
            _applicantAuthors[i].applicantTick(elapsed: _gameDaysElapsed);
            
            if _applicantAuthors[i].getMorale() < 1 {
                withdraw(applicantAt: i);
            }
            
            i -= 1;
        }
    }
    
    private func eventTick() {
        //Checks the eventList backwards so that expired Events
        //can be removed and not put the index out of bounds
        var i = eventList.count - 1;
        for _ in 0 ..< eventList.count {
            eventList[i].tick();
            if eventList[i].lifetime <= 0 {
                eventList.remove(at: i);
            }
            i -= 1;
        }
    }
    
    func add(_ event: Event) {
        //If there is a NewsEvent currently in the queue, put the next event
        //underneath it so that the News is always at the top
        if eventList.first is NewsEvent {//.debugDescription == "Optional(Blighty_Times.NewsEvent)" {
            eventList.insert(event, at: 1);
        } else {
            eventList.insert(event, at: 0);
        }
    }
    
    func chanceToSpawnNewsEvent() {
        //Checks to see if there is already news in the eventList
        //Right now, I only want one NewsEvent at a time
        if let event = eventList.first {
            if event is NewsEvent {
                return
            }
        }
        
        if Random(int: 0 ... 5) == 3 {
            add(NewsEvent())
        }
    }
    
    func weeklyReset() {
        //Player property reset
        _playerPausesLeft = Simulation._MAX_PAUSES;
        
        //Stat tracking reset
        _employeesHiredThisWeek = 0;
        _employeesFiredThisWeek = 0;
        _promotionsGivenThisWeek = 0;
        _articlesPublishedThisWeek = 0;
        _articleQualitiesThisWeek = [];
        for author in _employedAuthors { author.weeklyReset(); }
    }
    
    
    //Author Methods
    func hire(_ author: Author) {
        if _employedAuthors.count < _office.capacity {
            author.becomeHired();
            _employedAuthors.append(author);
            
            hireLoop: for i in 0 ..< _applicantAuthors.count {
                if _applicantAuthors[i].getName() == author.getName() {
                    _applicantAuthors.remove(at: i);
                    break hireLoop;
                }
            }
            
            _employeesHiredThisWeek += 1;
        } else {
            for event in eventList {
                if event is OfficeEvent {
                    return
                }
            }
                
            add(OfficeEvent(title: "Not Enough Room", message: "You cannot hire anyone right now. Your office is too full!", color: Event.neutralColor, image: _office.image))
        }
    }
    
    func fireEvent(forAuthorAt index: Int) {
        let name = _employedAuthors[index].getName()
        add(FiringEvent(title: "Fire " + name + "?",
                        message: "Firing " + name + " will lower the morale of the rest of the office",
                        color: Event.veryBadColor,
                        image: _employedAuthors[index].getPortrait()) {
            self.fire(authorAt: index)
        })
    }
    
    func fire(authorAt index: Int) {
        employeeLeaves(index);
        _employeesFiredThisWeek += 1;
        
        for author in employedAuthors {
            author.companyFiringMoraleReduction()
        }
    }
    
    func quit(authorAt index: Int) {
        let name = _employedAuthors[index].getName()
        
        //This ensures that when an authors quits you don't get any other event alert from them
        eventList.removeAll { (event) -> Bool in
            return event.message.contains(name)
        }
        
        add(EmployeeEvent(title: name + " Quit!",
                          message: name + " has left the company in disgust.",
                          color: Event.veryBadColor,
                          image: _employedAuthors[index].getPortrait()))
        
        employeeLeaves(index)
    }
    
    func employeeLeaves(_ index: Int) {
        //Tracks promotions given this week from employee
        //before removing them
        _promotionsGivenThisWeek += _employedAuthors[index].getPromotionsThisWeek();
        _employedAuthors.remove(at: index);
    }
    
    func withdraw(applicantAt index: Int) {
        _applicantAuthors.remove(at: index);
    }
    
    func spawnApplicant() {
        var auths = _employedAuthors + _applicantAuthors
        _applicantAuthors.append(Author(exluding: &auths));
        //add(ApplicantEvent(message: _applicantAuthors.last!.getName() + " sent you their application."));
    }
    
    func spawnStartingAuthor() {
        spawnApplicant();
        hire(_applicantAuthors[0]);
    }
    
    func spawnTestAuthor() {
        _employedAuthors.append(Author(portrait: UIImage(), name: "Test", topics: [TopicLibrary.list[0]], quality: 5, articleRate: ((Double(Simulation.TICKS_PER_DAY) / 60) / 30) * 3))
    }
    
    ///Checks 10 times per day if there should be a new applicant
    func chanceToSpawnApplicant() {
        if applicantAuthors.count == 0 {
            if _ticksElapsed % (Simulation.TICKS_PER_DAY / 10) == 0 {
                if Random(int: 1 ... 5) == 5 {
                    spawnApplicant()
                }
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
    
    func getCurrentNewsEventTopic() -> Topic? {
        if eventList.first is NewsEvent {
            return (eventList[0] as! NewsEvent).topic
        } else {
            return nil;
        }
    }
    
    func getArticlesPublishedThisWeek() -> Int {
        return _articlesPublishedThisWeek;
    }
    
    func getAverageQualityThisWeek() -> Int {
        var sum: Int = 0;
        
        for quality in _articleQualitiesThisWeek {
            sum += quality;
        }
        
        return sum > 0 ? sum / _articleQualitiesThisWeek.count : 0;
    }
    
    
    //Time Methods
    private func moveTimeForward() {
        _ticksElapsed += 1;
        
        if _ticksElapsed % _TICKS_PER_HOUR == 0 {
            _gameDayHoursElapsed = _gameDayHoursElapsed > 23 ? 1 : _gameDayHoursElapsed + 1;
        }
        
        //// This setup is for tracking time by minutes
        //
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
        
        companyTick()
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
    
    func pause() {
        _playerPausesLeft -= 1
    }
    
    func getPausesLeft() -> Int {
        return _playerPausesLeft;
    }
    
    
    //Population Methods
    func getRegionGraphLengths(with barLength: CGFloat) -> [CGFloat] {
        var lengths: [CGFloat] = []
        
        for region in population.regions {
            if let region = region {
                if region.getTotalSubscriberCount() == 0 {
                    lengths.append(CGFloat(0))
                } else {
                    lengths.append(barLength * ((CGFloat(region.getTotalSubscriberCount()) / CGFloat(region.getSize()))))
                }
            } else {
                lengths.append(0)
            }
        }
        
        return lengths
    }
    
    //Office methods
    func purchaseOffice(_ size: OfficeSize, starting: Bool = false) -> Bool {
        if !starting && _company.getFunds() < _officeList[size.rawValue].downPayment {
            add(OfficeEvent(title: "Insufficient Funds",
                            message: "Cannot buy that shiny new office. You're too poor!",
                            color: Event.neutralColor,
                            image: _officeList[size.rawValue].image))
            
            return false
        }
        
        _officeList[size.rawValue].purchased = true
        _office = _officeList[size.rawValue]
        
        if !starting {
            _company.payOfficeDownPayment(size: size)
            add(CompanyEvent(title: "New Digs!",
                             message: "You moved into a new, larger office! This will give you access to more regions, increasing your potential subscriber base. You will also now be able to hire up to \(_office.capacity) journalists at a time.",
                             color: Event.goodColor,
                             image: _officeList[size.rawValue].image))
        }
        
        for i in 0 ..< _office.size.rawValue {
            _officeList[i].purchased = true
        }
        
        var currentTopics: [Topic] = []
        for i in 0 ..< _population.regions.count {
            if _population.regions[i] == nil {
                _population.overwriteRegion(at: i, with: Region(with: size, excludedTopics: currentTopics))
                return true
            }
            
            currentTopics.append(contentsOf: _population.regions[i]!.getTopics())
        }
        
        return true
    }
}
