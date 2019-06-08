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
    private var _skillPoints: Int = 0;
    private var _topics: [Topic];
    private var _quality: Int;
    private var _articleRate: Double;
    private var _articleProgress: Double = 0;
    private var _articlesPublishedThisWeek: Int = 0;
    private var _articlesWrittenThisWeek: Int = 0;
    private var _daysSinceLastPublication: Int = 0;
    private var _daysEmployed: Int = 0; //Their salary raises every 15 days.
    private var _morale: Int; //Lowers when no articles published for # of ticks, raises when published, lowers slowly every day
    private var _lastKnownGameDaysElapsed: Int = 0;
    private var _salary: Int;
    
    //EmployeeEvent flags
    var hasPendingPromotion: Bool = false; //1 skill point available
    var hasCriticalMorale: Bool = false; //when morale is in the lowest or second lowest state
    var hasInfrequentPublished: Bool = false; //0 articles published in a week
    var hasPromotionAnxiety: Bool = false; //2 or more skill points available
    
    //Weekly stat properties
    private var _promotionsThisWeek: Int = 0;
    
    //Morale cooldown Properties
    private var _paycheckCooldown = 0;
    private var _promotionCooldown = 0;
    
    //EmployeeEvent cooldown properties
    private var _pendingPromotionCooldown: Int = 0
    private var _criticalMoraleCooldown: Int = 0;
    private var _infrequentPublishedColldown: Int = 0;
    private var _promotionAnxiety: Int = 0;
    
    //Constants
    private let PROGRESS_MAX: Double = Double(Simulation.TICKS_PER_DAY);
    fileprivate static let ARTICLE_RATE_MAX: Double = ((Double(Simulation.TICKS_PER_DAY) / 60) / 30) * 3; // 3 articles per day
    fileprivate static let ARTICLE_RATE_MIN: Double =  (Double(Simulation.TICKS_PER_DAY) / 60) / 30;      // 1:1 with the in-game day
    
    ///Is the public interface for adding new pre-made Authors
    ///in context of the currently employed authors
    init(exluding employedAuthors: inout [Author]) {
        let newAuthor = AuthorLibrary.getRandom(employedAuthors: &employedAuthors);
        _portrait = newAuthor.getPortrait();
        _name = newAuthor.getName();
        _experience = 0;
        _topics = newAuthor.getTopics();
        _quality = newAuthor.getQuality();
        _morale = newAuthor.getMorale();
        _articleRate = newAuthor.getRate();
        _salary = newAuthor.getSalary();
    }
    
    ///Handles the inits for the pre-made Authors with random stats
    ///Used by AuthorLibrary
    fileprivate init(portrait: UIImage, name: String) {
        _portrait = portrait;
        _name = name;
        _experience = 0;
        _topics = TopicLibrary.getRandomTopics();
        _quality = AuthorLibrary.getRandomQuality();
        _morale = Simulation.TICKS_PER_DAY / _quality;
        _articleRate = AuthorLibrary.getRandomRate();
        _salary = Int(_articleRate * 100) + (_quality * 10);
    }
    
    ///Public interface for custom author creation
    init(portrait: UIImage, name: String, topics: [Topic], quality: Int, articleRate: Double) {
        _portrait = portrait;
        _name = name;
        _experience = 0;
        _topics = topics;
        _quality = quality;
        _morale = Simulation.TICKS_PER_DAY / _quality;
        _articleRate = articleRate;
        _salary = Int(_articleRate * 200);
    }
    
    func employedTick(elapsed days: Int, moraleModifier: Double) {
        reduceCooldowns();
        
        if _lastKnownGameDaysElapsed != days {
            _lastKnownGameDaysElapsed = days;
            _daysEmployed += 1;
            _daysSinceLastPublication += 1
            reduceMorale(moraleModifier);
            
            if _daysSinceLastPublication > 5
            && _infrequentPublishedColldown == 0 {
                hasInfrequentPublished = true;
            }
        }
        
        checkforPromotion();
        increaseArticleProgress();
    }
    
    func applicantTick(elapsed days: Int) {
        if _lastKnownGameDaysElapsed != days {
            _lastKnownGameDaysElapsed = days;
            _daysEmployed += 1;
        }
        
        adjustApplicantMorale();
    }
    
    func reduceCooldowns() {
        _paycheckCooldown -= _paycheckCooldown > 0 ? 1 : 0;
        _promotionCooldown -= _promotionCooldown > 0 ? 1 : 0;
        
        _pendingPromotionCooldown -= _pendingPromotionCooldown > 0 ? 1 : 0;
        _criticalMoraleCooldown -= _criticalMoraleCooldown > 0 ? 1 : 0;
        _infrequentPublishedColldown -= _infrequentPublishedColldown > 0 ? 1 : 0;
        _promotionAnxiety -= _promotionAnxiety > 0 ? 1 : 0;
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
    
    func setIncreasedQuality() {
        _quality += 1;
    }
    
    func getQualitySymbol() -> String {
        return statString(from: 1, with: _quality, to: 10)
    }
    
    func getRate() -> Double {
        return _articleRate;
    }
    
    func hasMaxRate() -> Bool {
        return _articleRate == Author.ARTICLE_RATE_MAX
    }
    
    func setIncreasedRate() {
        //Increases rate by a 10th of the difference between the min and max rates
        let rateIncrease: Double = (Author.ARTICLE_RATE_MAX - Author.ARTICLE_RATE_MIN) / 10.0;
        _articleRate = _articleRate + rateIncrease > Author.ARTICLE_RATE_MAX ? Author.ARTICLE_RATE_MAX : _articleRate + rateIncrease;
    }
    
    func getRateSymbol() -> String {
        return statString(from: Author.ARTICLE_RATE_MIN, with: _articleRate, to: Author.ARTICLE_RATE_MAX)
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
        return statString(from: 0, with: _morale, to: 1000)
    }
    
    func getMoraleColor() -> UIColor {
        if _promotionCooldown > 0 || _paycheckCooldown > 0 {
            return statColor(from: 0, with: 1, to: 1)
        } else {
            return statColor(from: 200, with: _morale, to: 1000)
        }
    }
    
    private func statString(from min: Int, with actual:Int, to max: Int) -> String {
        return statString(from: Double(min), with: Double(actual), to: Double(max))
    }
    
    private func statString(from min: Double, with actual: Double, to max: Double) -> String {
        if max == 0  ||
           min > max ||
           actual < min { return "" }
        
        var statString = "|"
        let difference = max - min
        let increment = difference / 10
        
        for i in 1 ..< 10 {
            if actual > min + increment * Double(i) {
                statString += "|"
            } else {
                break
            }
        }
        
        return statString
    }
    
    private func statColor(from low: Int, with actual:Int, to high: Int) -> UIColor {
        if actual >= high {
            return #colorLiteral(red: 0.3169804215, green: 0.9253683686, blue: 0, alpha: 1)
        } else if actual <= low {
            return #colorLiteral(red: 0.8795482516, green: 0.1792428792, blue: 0.3018780947, alpha: 1)
        } else {
            return  #colorLiteral(red: 0, green: 0.4802635312, blue: 0.9984222054, alpha: 1)
        }
    }
    
    private func reduceMorale(_ moraleModifier: Double) {
        var moraleDecay = -1
        
        if _paycheckCooldown == 0 {
            if _daysEmployed > 7 {
                moraleDecay -= 50;
                
                if _articlesPublishedThisWeek < 1 {
                    moraleDecay -= 50;
                }
            } else if _daysEmployed > 30 {
                moraleDecay -= 200;
            }
        }
        
        _morale -= moraleDecay / moraleModifier
        
        if _morale <= 200 && _criticalMoraleCooldown == 0 {
            hasCriticalMorale = true;
        }
    }
    
    private func adjustApplicantMorale() {
        _morale -= 1;
    }
    
    func getSalary() -> Int {
        return _salary;
    }
    
    func setNewSalary() {
        _salary += Int(_articleRate * 10) + (_quality * 10);
    }
    
    func getCommission() -> Int {
        return getSalary() * 2;
    }
    
    func getPublishedThisWeek() -> Int {
        return _articlesPublishedThisWeek;
    }
    
    func publishArticle() {
        _articlesPublishedThisWeek += 1;
        _daysSinceLastPublication = 0;
        increaseExperience(Double(_quality + 5) * 5);
        _paycheckCooldown = Simulation.TICKS_PER_DAY / 12;
    }
    
    func getSubmittedThisWeek() -> Int {
        return _articlesWrittenThisWeek;
    }
    
    func submitArticle() {
        _articlesWrittenThisWeek += 1;
        _articleProgress = 0;
        increaseExperience(Double(_quality));
    }
    
    func getExperience() -> Double {
        return _experience;
    }
    
    func increaseExperience(_ exp: Double) {
        _morale += Int(exp * 0.25);
        _experience += exp;
    }
    
    func getSkillPoints() -> Int {
        return _skillPoints;
    }
    
    func checkforPromotion() {
        if getSeniorityLevel() != _currentLevel {
            _skillPoints += 1;
            _currentLevel = getSeniorityLevel();
            
            if _skillPoints > 2 && _promotionAnxiety == 0 {
                hasPromotionAnxiety = true;
            } else if _skillPoints == 1 && _pendingPromotionCooldown == 0 {
                hasPendingPromotion = true;
            }
        }
    }
    
    func promoteQuality() {
        if _skillPoints > 0 {
            setIncreasedQuality();
            promote();
        }
    }
    
    func promoteSpeed() {
        if _skillPoints > 0 {
            setIncreasedRate();
            promote();
        }
    }
    
    private func promote() {
        setNewSalary();
        _skillPoints -= 1;
        _promotionsThisWeek += 1;
        _promotionCooldown = Simulation.TICKS_PER_DAY / 2;
    }
    
    func getPromotionsThisWeek() -> Int {
        return _promotionsThisWeek;
    }
    
    func weeklyReset() {
        _promotionsThisWeek = 0;
    }
    
    func newArticleTopic() -> Topic {
        return _topics[Random(index: _topics.count)];
    }
    
    func becomeHired() {
        _daysEmployed = 0;
        _morale = 500;
    }
}

class AuthorLibrary {
    private static let _AUTHORS: [Author] = [
        Author(portrait: #imageLiteral(resourceName: "SuzyJoe"), name: "Suzy Joe"),
        Author(portrait: #imageLiteral(resourceName: "JackBricklayer"), name: "Jack Bricklayer"),
        Author(portrait: #imageLiteral(resourceName: "FrankBottomwealth"), name: "Frank Bottomwealth"),
        Author(portrait: #imageLiteral(resourceName: "HaroldKnickers"), name: "Harold Knickers"),
        Author(portrait: #imageLiteral(resourceName: "TheresaFroshet"), name: "Theresa Froshet"),
        Author(portrait: #imageLiteral(resourceName: "LincolnMatherlips"), name: "Lincoln Matherlips"),
        Author(portrait: #imageLiteral(resourceName: "FreddiePlicks"), name: "Freddie Plicks"),
        Author(portrait: #imageLiteral(resourceName: "WendyMysten"), name: "Wendy Mysten"),
        Author(portrait: #imageLiteral(resourceName: "ElaineMendihooks"), name: "Elaine Mendihooks"),
        Author(portrait: #imageLiteral(resourceName: "ChuckVandel"), name: "Chuck Vandel"),
        Author(portrait: #imageLiteral(resourceName: "GregHeartis"), name: "Greg Heartis"),
        Author(portrait: #imageLiteral(resourceName: "JesseFlickmaster"), name: "Jesse Flickmaster"),
        Author(portrait: #imageLiteral(resourceName: "NicholeTremble"), name: "Nichole Tremble"),
        Author(portrait: #imageLiteral(resourceName: "LeonardTeaspray"), name: "Leonard Teaspray"),
        Author(portrait: #imageLiteral(resourceName: "CatherineHumble"), name: "Catherine Humble"),
        Author(portrait: #imageLiteral(resourceName: "SamuelBarth"), name: "Samuel Barth"),
        Author(portrait: #imageLiteral(resourceName: "JackieWesterpile"), name: "Jackie Westerpile"),
        Author(portrait: #imageLiteral(resourceName: "PeteUnderknuckle"), name: "Pete Underknuckle"),
        Author(portrait: #imageLiteral(resourceName: "ArthurTinmonk"), name: "Arthur Tinmonk"),
        Author(portrait: #imageLiteral(resourceName: "RichardFeak"), name: "Richard Feak"),
        Author(portrait: #imageLiteral(resourceName: "TimothyWhiskerly"), name: "Timothy Whiskerly"),
        Author(portrait: #imageLiteral(resourceName: "MatthewSnote"), name: "Matthew Snote"),
        Author(portrait: #imageLiteral(resourceName: "BrittanyBlossoms"), name: "Brittany Blossoms"),
        Author(portrait: #imageLiteral(resourceName: "NigelTuntilly"), name: "Nigel Tuntilly"),
        Author(portrait: #imageLiteral(resourceName: "JamesHeath"), name: "James Heath"),
        Author(portrait: #imageLiteral(resourceName: "MeresaPlaingull"), name: "Meresa Plaingull"),
        Author(portrait: #imageLiteral(resourceName: "NormanShugal"), name: "Norman Shugal"),
        Author(portrait: #imageLiteral(resourceName: "LizzyFrankly"), name: "Lizzy Frankly"),
        Author(portrait: #imageLiteral(resourceName: "LesBeastline"), name: "Les Beastline"),
        Author(portrait: #imageLiteral(resourceName: "HelgaHarbinger"), name: "Helga Harbinger"),
        Author(portrait: #imageLiteral(resourceName: "ChazGesture"), name: "Chaz Gesture"),
        Author(portrait: #imageLiteral(resourceName: "FletcherKlankapot"), name: "Fletcher Klankapot"),
        Author(portrait: #imageLiteral(resourceName: "NathanZimpeck"), name: "Nathan Zimpeck"),
        Author(portrait: #imageLiteral(resourceName: "OsmundHoneyfront"), name: "Osmund Honeyfront"),
        Author(portrait: #imageLiteral(resourceName: "TerrySmackeral"), name: "Terry Smackeral"),
        Author(portrait: #imageLiteral(resourceName: "OliverKlipfin"), name: "Oliver Klipfin"),
        Author(portrait: #imageLiteral(resourceName: "AbbigailMowrett"), name: "Abbigail Mowrett"),
        Author(portrait: #imageLiteral(resourceName: "JenThistlebeak"), name: "Jen Thistlebeak"),
        Author(portrait: #imageLiteral(resourceName: "HankPrestal"), name: "Hank Prestal"),
        Author(portrait: #imageLiteral(resourceName: "JeromeFilks"), name: "Jerome Filks"),
        Author(portrait: #imageLiteral(resourceName: "JustinHestile"), name: "Justin Hestile"),
        Author(portrait: #imageLiteral(resourceName: "MarieGilphon"), name: "Marie Gilphon"),
        Author(portrait: #imageLiteral(resourceName: "EmmaVenbracket"), name: "Emma Venbracket"),
        Author(portrait: #imageLiteral(resourceName: "CharlotteKlumph"), name: "Charlotte Klumph"),
        Author(portrait: #imageLiteral(resourceName: "AvaEstmire"), name: "Ava Estmire"),
        Author(portrait: #imageLiteral(resourceName: "IkeCrimmelflank"), name: "Ike Crimmelflank"),
        Author(portrait: #imageLiteral(resourceName: "KaylinSprockets"), name: "Kaylin Sprockets"),
        Author(portrait: #imageLiteral(resourceName: "SnuttyLeftcut"), name: "Snutty Leftcut"),
        Author(portrait: #imageLiteral(resourceName: "MarcusGuildabreck"), name: "Marcus Guildabreck"),
        Author(portrait: #imageLiteral(resourceName: "BillFesterville"), name: "Bill Festerville")
    ];
    
    var blank: Author = Author(portrait: UIImage(), name: "blank", topics: [], quality: 1, articleRate: 0);
    
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

