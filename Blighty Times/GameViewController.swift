//
//  GameViewController.swift
//  BlightyTimes
//
//  Created by Zachary Duncan on 8/15/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, StateObject {
    var delegate: MainMenu?
    
    //Article Outlets & Properties
    @IBOutlet weak var publishButton: UIButton!
    
    @IBOutlet weak var NE_articleSlotsTop: UIStackView!
    @IBOutlet weak var NE_articleSlotsBottom: UIStackView!
    @IBOutlet weak var NE_bonusTopic: UILabel!
    @IBOutlet weak var NE_bonusLabel: UILabel!
    @IBOutlet weak var pendingSlotsFullWarning: UILabel!
    @IBOutlet weak var articlePane: UIView!
    @IBOutlet weak var articleSlotsStack: UIStackView!
    @IBOutlet weak var articleSlotsTop: UIStackView!
    @IBOutlet weak var articleSlotsMiddle: UIStackView!
    @IBOutlet weak var articleSlotsBottom: UIStackView!
    @IBOutlet weak var articleTileHight: NSLayoutConstraint!
    @IBOutlet weak var articleTileWidth: NSLayoutConstraint!
    
    var articleTiles: NSPointerArray = .weakObjects();
    var NE_articleTiles: NSPointerArray = .weakObjects();
    @IBOutlet var NE_viewPositions: [UIView]!
    
    var lastSelectedIndexPath: IndexPath = IndexPath(row: 0, section: 0);
    @IBOutlet weak var employedAuthorsTable: UITableView!;
    @IBOutlet weak var applicantAuthorsTable: UITableView!
    @IBOutlet weak var applicantsButton: UIButton!
    @IBOutlet weak var applicantsCountBadge: UILabel!
    @IBOutlet weak var journalistsButton: UIButton!
    var applicantBadgeCooldown: Int = 0;
    
    @IBOutlet weak var dayOfTheWeek: UILabel!
    @IBOutlet weak var timeOfDay: UILabel!
    @IBOutlet weak var timelineWidth: NSLayoutConstraint!
    @IBOutlet weak var timePlayHeadConstraint: NSLayoutConstraint!
    @IBOutlet weak var pausesLeft: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    
    //Data Tracking Outlets
    @IBOutlet weak var companyFunds: UILabel!
    @IBOutlet weak var yesterdaysProfit: UILabel!
    @IBOutlet weak var hiredAuthors: UILabel!
    @IBOutlet weak var totalSubscribers: UILabel!
    @IBOutlet weak var newSubscribers: UILabel!
    @IBOutlet var regionTopicsLabels: [UILabel]!
    @IBOutlet var regionBars: [UIView]!
    @IBOutlet var regionBarConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var regionBarsMaxConstraint: NSLayoutConstraint!
    @IBOutlet var regionBarProgressSymbols: [UILabel]!
    @IBOutlet weak var eventsTable: UITableView!
    @IBOutlet weak var noEventsSymbol: UILabel!
    @IBOutlet weak var newsBonusTopicOverlay: UIView!
    @IBOutlet weak var newsBonusTopic: UILabel!
    
    //Moving Tile Outlets and Properties
    @IBOutlet weak var movingTileReferenceView: UIView!
    @IBOutlet weak var movingTileTitle: UILabel!
    @IBOutlet weak var movingTileAuthor: UILabel!
    var movingTileIndex: Int?;
    var NE_movingTileIndex: Int?;
    var lastknownTileLocation: CGPoint?;
    
    //Game Properties
    var sim = Simulation();
    private var gameTimer: Timer!;
    var stateMachine: StateMachine!
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        stateMachine = StateMachine(state: PlayState(), stateObject: self)
        
        sim.start();
        createTiles();
        startGameTime();
        setupAesthetics();
    }
    
    @objc func tick() {
        //Game Simulation
        sim.tick();
        
        //Animate UI changes
        employedAuthorsTable.reloadData();
        
        if eventsTable.numberOfRows(inSection: 0) != sim.eventList.count {
            noEventsSymbol.isHidden = sim.eventList.count == 0 ? false : true;
            eventsTable.reloadSections(IndexSet(integersIn: 0...0), with: .fade);
        }
        
        dayOfTheWeek.text = sim.getDayOfTheWeek();
        timeOfDay.text = sim.getTimeOfDay();
        timePlayHeadConstraint.constant = sim.getPlayheadLength(maxLength: timelineWidth.constant);
        setRegionTopicsUI();
        
        
        //Cleans up dead articles
        for i in 0 ..< articleTiles.count {
            if let tile = articleTiles.object(at: i) {
                if tile.article.getLifetime() <= 0 || tile.article.getTitle().count < 5 {
                    sim.removeFromPending(article: tile.article)
                    tile.setBlank();
                } else if tile.article.getLifetime() <= Double(Simulation.TICKS_PER_DAY / 24 * 3) {
                    //Start blinking animation here
                }
            }
        }
        
        for i in 0 ..< NE_articleTiles.count {
            if let tile = NE_articleTiles.object(at: i) {
                if tile.article.getLifetime() <= 0 || tile.article.getTitle().count < 5 {
                    tile.setBlank();
                } else if tile.article.getLifetime() <= Double(Simulation.TICKS_PER_DAY / 24 * 3) {
                    //Start blinking animation here
                }
            }
        }
        
        if sim.isEndOfDay() {
            publishButton.isEnabled = false;
            stopGameTime();
            
            for i in 0 ..< self.NE_articleTiles.count {
                self.NE_articleTiles.object(at: i)!.setBlank();
            }
            
            updateDataPanels();
        }
        
        //Adds in new articles
        a: for article in 0 ..< sim.newArticles.count {
            b: for tileIndex in 0 ..< articleTiles.count {
                if let tile = articleTiles.object(at: tileIndex) {
                    if tile.article.getTitle() == ArticleLibrary.blank.getTitle() {
                        tile.set(article: &sim.newArticles[article]);
                        
                        break b;
                    }
                }
            }
        }
        
        sim.syncNewArticles();
        
        if sim.writtenArticles.count == 12 {
            pendingSlotsFullWarning.isHidden = false;
        } else {
            pendingSlotsFullWarning.isHidden = true;
        }
        
        //Handles the behavior of the moving tile from pending
        for i in 0 ..< articleTiles.count {
            if articleTiles.object(at: i)!.isTouched && movingTileIndex != i {
                movingTileIndex = i;
                
                movingTileTitle.text = articleTiles.object(at: i)!.article.getTitle();
                movingTileAuthor.text = articleTiles.object(at: i)!.article.getAuthor().getName();
                movingTileReferenceView.backgroundColor = articleTiles.object(at: i)!.article.getTopic().getColor();
            }
        }
        
        //Handles the behavior of the moving tile from NE
        for i in 0 ..< NE_articleTiles.count {
            if NE_articleTiles.object(at: i)!.isTouched && NE_movingTileIndex != i {
                NE_movingTileIndex = i;
                
                movingTileTitle.text = NE_articleTiles.object(at: i)!.article.getTitle();
                movingTileAuthor.text = NE_articleTiles.object(at: i)!.article.getAuthor().getName();
                movingTileReferenceView.backgroundColor = NE_articleTiles.object(at: i)!.article.getTopic().getColor();
            }
        }
        
        //Handles the Applicants counter visibility
        if applicantBadgeCooldown == 0 {
            if sim.applicantAuthors.count > 0 && applicantsButton.isEnabled == true {
                applicantsCountBadge.text = "\(sim.applicantAuthors.count)";
                applicantsCountBadge.isHidden = false;
            } else {
                applicantsCountBadge.isHidden = true;
                applicantBadgeCooldown = 10;
            }
        } else {
            applicantBadgeCooldown -= 1;
            applicantAuthorsTable.reloadData();
        }
    }
    
    @IBAction func pauseButton(_ sender: Any) {
        stateMachine.handle(input: .pauseButton)
        
        if stateMachine.state is PauseState {
            pauseButton.setTitle("▶︎", for: .normal);
        } else if stateMachine.state is PlayState {
            if sim.getPausesLeft() == 0 {
                pauseButton.setTitle("᰽", for: .normal);
            } else {
                pauseButton.setTitle("||", for: .normal);
            }

        }
        
        pausesLeft.text = "\(sim.getPausesLeft())";
//        if stateMachine.state is PlayState || stateMachine.state is PauseState {
//            sim.pauseplayButtonPressed();
//
//            if sim.isPaused() {
//                pauseButton.setTitle("▶︎", for: .normal);
//                pausesLeft.text = "\(sim.getPausesLeft())";
//                stopGameTime();
//            } else {
//                if sim.getPausesLeft() == 0 {
//                    pauseButton.setTitle("᰽", for: .normal);
//                    startGameTime();
//                    pauseButton.isEnabled = false;
//                } else {
//                    pauseButton.setTitle("||", for: .normal);
//                    startGameTime();
//                }
//            }
//        }
    }
    
    func startGameTime() {
        gameTimer = Timer.scheduledTimer(timeInterval: Simulation.TICK_RATE, target: self, selector: #selector(tick), userInfo: nil, repeats: true);
    }
    
    func stopGameTime() {
        gameTimer.invalidate();
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender for: Any?) {
        if segue.identifier == "scoreSegue" {
            if let scoreVC = segue.destination as? ScoreCardViewController {
                scoreVC.iweekNumber = sim.getWeekNumber();
                
                scoreVC.ipaidToEmployees = sim.company.getPaidToEmployeesThisWeek();
                scoreVC.iearnedRevenue = sim.company.getEarnedRevenueThisWeek();
                scoreVC.isubscriberFluxuation = sim.population.getSubscriberFluxuationThisWeek();
                
                scoreVC.iemployeesHired = sim.getEmployeesHiredThisWeek();
                scoreVC.iemployeesFired = sim.getEmployeesFiredThisWeek();
                scoreVC.ipromotionsGiven = sim.getPromotionsGivenThisWeek();
                scoreVC.iarticlesPublished = sim.getArticlesPublishedThisWeek();
                scoreVC.iaverageQuality = sim.getAverageQualityThisWeek();
                
                sim.company.weeklyReset();
                sim.population.weeklyReset();
                sim.weeklyReset();
            }
        } else if segue.identifier == "inGameMenuSegue" {
            if let menu = segue.destination as? InGameMenu {
                stateMachine.handle(input: .pause)
                menu.delegate = self
            }
        }
    }
    
    @IBAction func unwindToGame(segue:UIStoryboardSegue) {
        //startGameTime();
        stateMachine.handle(input: .play)
        //Explicit repainting of pauses label. The sim resets the number every week.
        pausesLeft.text = "\(sim.getPausesLeft())";
    }
    
    func createTiles() {
        view.layoutIfNeeded();
        
        // NE Tiles
        for i in 1 ... 6 {
            guard let tile = Bundle.main.loadNibNamed("ArticleTile", owner: self, options: nil)?.first as? ArticleTile else { fatalError(); }
            
            tile.setBlank();
            tile.addConstraint(NSLayoutConstraint(item: tile, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: articleTileHight.constant));
            tile.addConstraint(NSLayoutConstraint(item: tile, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: articleTileWidth.constant));
            tile.layer.opacity = 0;
            tile.addGestureRecognizer(pan());
            
            NE_articleTiles.addObject(tile);
            
            if i <= 3 {
                NE_articleSlotsTop.addArrangedSubview(tile);
            } else {
                NE_articleSlotsBottom.addArrangedSubview(tile);
            }
        }
        
        // Pending Tiles
        for i in 1 ... 12 {
            guard let tile = Bundle.main.loadNibNamed("ArticleTile", owner: self, options: nil)?.first as? ArticleTile else { fatalError(); }
            
            tile.setBlank();
            tile.addConstraint(NSLayoutConstraint(item: tile, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: articleTileHight.constant));
            tile.addGestureRecognizer(pan());
            
            articleTiles.addObject(tile);
            
            if i <= 4 {
                articleSlotsTop.addArrangedSubview(tile);
            } else if i <= 8 {
                articleSlotsMiddle.addArrangedSubview(tile);
            } else {
                articleSlotsBottom.addArrangedSubview(tile);
            }
        }
    }
    
    func setupAesthetics() {
        movingTileReferenceView.addShadow(radius: 7, height: 8, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2011451199));
        applicantsCountBadge.roundCorners(withIntensity: .full);
        applicantsButton.layer.opacity = 0.3;
        journalistsButton.isEnabled = false;
        
        for node in NE_viewPositions {
            node.addBorders(width: 3.0, color: UIColor.black.cgColor);
        }
        
        setRegionTopics();
        updateDataPanels();
        
        stateMachine.force(PlayState())
    }
    
    func setRegionTopicsUI() {
        //Makes sure there is a News Topic to show
        if sim.getCurrentNewsEventTopic() != nil {
            newsBonusTopicOverlay.isHidden = false;
            newsBonusTopicOverlay.backgroundColor = sim.getCurrentNewsEventTopic()?.getColor();
            newsBonusTopic.text = sim.getCurrentNewsEventTopic()!.getName();
            NE_bonusTopic.text = sim.getCurrentNewsEventTopic()!.getName();
            NE_bonusTopic.textColor = sim.getCurrentNewsEventTopic()!.getColor();
            NE_bonusLabel.textColor = sim.getCurrentNewsEventTopic()!.getColor();
        } else {
            //Makes sure its not processing the same UI info repeatedly
            if !newsBonusTopicOverlay.isHidden {
                setRegionTopics();
                
                newsBonusTopicOverlay.isHidden = true;
                NE_bonusTopic.text = "Topic";
                NE_bonusTopic.textColor = #colorLiteral(red: 0.6442400406, green: 0.6506186548, blue: 0.6506186548, alpha: 1);
                NE_bonusLabel.textColor = #colorLiteral(red: 0.6442400406, green: 0.6506186548, blue: 0.6506186548, alpha: 1);
            }
        }
    }
    
    func setRegionTopics() {
        for i in 0 ..< sim.population.regions.count {
            var topicText = "";
            for j in 0 ..< sim.population.regions[i].getTopics().count {
                topicText += sim.population.regions[i].getTopics()[j].getApprovalSymbol() + " " + sim.population.regions[i].getTopics()[j].getName();
                if j < 3 { topicText += "\n"; }
            }
            regionTopicsLabels[i].text = topicText;
        }
    }
    
    func pan() -> UIPanGestureRecognizer {
        var panRecognizer = UIPanGestureRecognizer()

        panRecognizer = UIPanGestureRecognizer (target: self, action: #selector(handlePan(recognizer: )));
        panRecognizer.minimumNumberOfTouches = 1;
        panRecognizer.maximumNumberOfTouches = 1;
        panRecognizer.cancelsTouchesInView = false;
        return panRecognizer;
    }
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        if !(stateMachine.state is PlayState) { /*print("[STATE MACHINE]  * Drag prevented");*/ return }
        //print("[STATE MACHINE]  * Drag enabled")
        
        //Dragging for Pending Tiles
        if let index = movingTileIndex {
            if let tile = articleTiles.object(at: index) {

                if recognizer.state == .began {
                    tile.layer.opacity = 0;

                    if index < 4 {
                        lastknownTileLocation = CGPoint(x: tile.center.x + 20,
                                                        y: (articleSlotsStack.frame.maxY - 10) - (articleSlotsTop.frame.height * 2.5));
                    } else if index < 8 {
                        lastknownTileLocation = CGPoint(x: tile.center.x + 20,
                                                        y: (articleSlotsStack.frame.maxY - 5) - (articleSlotsMiddle.frame.height * 1.5));
                    } else if index < 12 {
                        lastknownTileLocation = CGPoint(x: tile.center.x + 20,
                                                        y: (articleSlotsStack.frame.maxY) - (articleSlotsBottom.frame.height * 0.5));
                    }

                    movingTileReferenceView.center = lastknownTileLocation!;
                    movingTileReferenceView.isHidden = false;
                }// End .began



                let translation = recognizer.translation(in: self.view);
                movingTileReferenceView.center = CGPoint(x: movingTileReferenceView.center.x + translation.x,
                                                         y: movingTileReferenceView.center.y + translation.y);
                recognizer.setTranslation(CGPoint.zero, in: self.view);



                if recognizer.state == .ended || recognizer.state == .cancelled {
                    let dropLocation = recognizer.location(in: articlePane);
//                    var NE_newLocation: CGPoint? = nil;
                    var NE_newIndex: Int? = nil;

                    hitLoop: for ne_view in NE_viewPositions {
                        if dropLocation.x > ne_view.frame.minX &&
                            dropLocation.y > ne_view.frame.minY &&
                            dropLocation.x < ne_view.frame.maxX &&
                            dropLocation.y < ne_view.frame.maxY {

                            if sim.addToNextEdition(article: &tile.article, index: ne_view.tag) {
                                lastknownTileLocation = ne_view.center;
                                NE_newIndex = ne_view.tag;
//                                lastknownTileLocation = nil;

                                NE_articleTiles.object(at: ne_view.tag)!.set(article: &sim._nextEditionArticles[ne_view.tag]);
                                NE_articleTiles.object(at: ne_view.tag)!.layer.opacity = 0;
                            }

                            break hitLoop;
                        }
                    }

                    //Animate movingTileReferenceView back to its destination
                    UIView.animate(withDuration: 0.2, animations: {
                        self.movingTileReferenceView.center = self.lastknownTileLocation!;
                    }) { (finished) in
                        if NE_newIndex != nil {
                            self.NE_articleTiles.object(at: NE_newIndex!)?.layer.opacity = 1;
                            tile.setBlank();
                        }

                        tile.layer.opacity = 1;
                        self.movingTileIndex = nil;
                        self.movingTileReferenceView.isHidden = true;
                    }
                }// End .ended || .cancelled
            }

        //Dragging for NE Tiles
        } else if let index = NE_movingTileIndex {
            if let tile = NE_articleTiles.object(at: index) {
                if recognizer.state == .began {
                    tile.layer.opacity = 0;

                    lastknownTileLocation = NE_viewPositions[index].center;

                    movingTileReferenceView.center = lastknownTileLocation!;
                    movingTileReferenceView.isHidden = false;
                }// End .began



                let translation = recognizer.translation(in: self.view);
                movingTileReferenceView.center = CGPoint(x: movingTileReferenceView.center.x + translation.x, y: movingTileReferenceView.center.y + translation.y);
                recognizer.setTranslation(CGPoint.zero, in: self.view);



                //One of three things can happen when tile from NE is dropped
                //1. It's in the same spot or another non-blank NE slot -- Must slide back to its orig position
                //2. It's in another blank NE slot -- It must slide into its new position
                //3. It's anywhere else -- Either animates to first available Pending slot or back to its own slot
                if recognizer.state == .ended || recognizer.state == .cancelled {
                    let dropLocation = recognizer.location(in: articlePane);
                    var NE_newIndex: Int? = nil;
                    var Pending_newIndex: Int? = nil;

                    hitLoop: for ne_view in NE_viewPositions {
                        if dropLocation.x > ne_view.frame.minX &&
                            dropLocation.y > ne_view.frame.minY &&
                            dropLocation.x < ne_view.frame.maxX &&
                            dropLocation.y < ne_view.frame.maxY {

                            lastknownTileLocation = NE_viewPositions[index].center;
                            NE_newIndex = index;

                            // If the NE slot dropped on is blank we put it down, if not, it goes back to lastknownTileLocation
                            if sim.changeIndexNextEdition(from: index, to: ne_view.tag) {
                                lastknownTileLocation = ne_view.center;
                                NE_newIndex = ne_view.tag;
                                NE_articleTiles.object(at: ne_view.tag)!.set(article: &tile.article);//sim._nextEditionArticles[ne_view.tag]);
                                NE_articleTiles.object(at: ne_view.tag)!.layer.opacity = 0;
                            }

                            break hitLoop;
                        }
                    }

                    // if NE_newIndex is still nil here that means we need to find the Pending_newIndex & location
                    if NE_newIndex == nil {
                        pendLoop: for i in 0 ..< articleTiles.count {
                            if articleTiles.object(at: i)!.article === ArticleLibrary.blank {
                                //Unassign from NE back to Pending
                                if sim.backToPending(ne_index: index) {
                                    if i < 4 {
                                        lastknownTileLocation = CGPoint(x: (tile.frame.width * CGFloat(i)) + tile.center.x + 20,
                                                                        y: (articleSlotsStack.frame.maxY - 10) - (articleSlotsTop.frame.height * 2.5));
                                    } else if i < 8 {
                                        lastknownTileLocation = CGPoint(x: (tile.frame.width * CGFloat(i)) + tile.center.x + 20,
                                                                        y: (articleSlotsStack.frame.maxY - 5) - (articleSlotsMiddle.frame.height * 1.5));
                                    } else if i < 12 {
                                        lastknownTileLocation = CGPoint(x: (tile.frame.width * CGFloat(i)) + tile.center.x + 20,
                                                                        y: (articleSlotsStack.frame.maxY) - (articleSlotsBottom.frame.height * 0.5));
                                    }
                                    Pending_newIndex = i;
                                    articleTiles.object(at: i)!.set(article: &tile.article);
                                    articleTiles.object(at: i)!.layer.opacity = 0;
                                }

                                break pendLoop;
                            }
                        }
                    }

                    //If both NE and Pending indices are nil the tile needs to head back to its orig location
                    if Pending_newIndex == nil && NE_newIndex == nil {
                        NE_newIndex = index;
                    }

                    //Animate movingTileReferenceView to its destination
                    UIView.animate(withDuration: 0.1, animations: {
                        self.movingTileReferenceView.center = self.lastknownTileLocation!;
                    }) { (finished) in
                        if NE_newIndex != nil {
                            self.NE_articleTiles.object(at: NE_newIndex!)!.layer.opacity = 1;
                            if NE_newIndex != index {
                                tile.setBlank();
                            }
                        } else {
                            self.articleTiles.object(at: Pending_newIndex!)!.layer.opacity = 1;
                            tile.setBlank();
                        }

                        tile.layer.opacity = 1;
                        self.movingTileIndex = nil;
                        self.movingTileReferenceView.isHidden = true;
                    }
                }// End .ended || .cancelled
            }
        }
    }
    
    func updateDataPanels() {
        stopGameTime();
        
        //Update Company statistics
        companyFunds.text = sim.company.getFunds().dollarFormat();
        companyFunds.textColor = sim.company.getFunds() < 0 ? .red : .black;
        yesterdaysProfit.text = sim.company.getYesterdaysProfit().dollarFormat();
        yesterdaysProfit.textColor = sim.company.getYesterdaysProfit() < 0 ? .red : .black;
        totalSubscribers.text = sim.population.getTotalSubscriberCount().commaFormat();
        newSubscribers.text = sim.population.getNewSubscriberCount().commaFormat();
        hiredAuthors.text = "\(sim.employedAuthors.count)";
        
        //Update Region Bars and Topics
        for i in 0 ..< self.regionBars.count {
            if self.sim.population.regions[i].getNewSubscriberCount() > 0 {
                self.regionBars[i].backgroundColor =  #colorLiteral(red: 0.4885490545, green: 0.7245667335, blue: 0.9335739213, alpha: 1);
                self.regionBarProgressSymbols[i].text = "▲";
            } else if self.sim.population.regions[i].getNewSubscriberCount() < 0 {
                self.regionBars[i].backgroundColor = #colorLiteral(red: 0.9179712534, green: 0.522530973, blue: 0.5010649562, alpha: 1);
                self.regionBarProgressSymbols[i].text = "▼";
            } else {
                self.regionBars[i].backgroundColor = #colorLiteral(red: 0.7368394732, green: 0.736964643, blue: 0.7368229032, alpha: 1);
                self.regionBarProgressSymbols[i].text = "⏤";
            }
            
            if self.sim.population.regions[i].getTotalSubscriberCount() == 0 {
                self.regionBarConstraints[i].constant = 0;
            } else {
                self.regionBarConstraints[i].constant = self.regionBarsMaxConstraint.constant * (CGFloat(self.sim.population.regions[i].getTotalSubscriberCount()) / CGFloat(self.sim.population.regions[i].getSize()));
            }
        }
        
        setRegionTopics()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded();
        }) { (finished) in
            self.stateMachine.handle(input: .publishComplete)
            
            if self.sim.isEndOfWeek() {
                self.stateMachine.handle(input: .weekend)
                self.performSegue(withIdentifier: "scoreSegue", sender: nil)
            }
            
            self.publishButton.isEnabled = true;
        }
    }
    
    @IBAction func journalistsButton(_ sender: Any) {
        journalistsButton.isEnabled = false;
        journalistsButton.layer.opacity = 1;
        applicantsButton.isEnabled = true;
        applicantsButton.layer.opacity = 0.3;
        
        applicantAuthorsTable.isHidden = true;
    }
    
    @IBAction func applicantsButton(_ sender: Any) {
        applicantsCountBadge.isHidden = true;
        applicantBadgeCooldown = 10
        
        applicantsButton.isEnabled = false;
        applicantsButton.layer.opacity = 1;
        journalistsButton.isEnabled = true;
        journalistsButton.layer.opacity = 0.3;
        
        applicantAuthorsTable.isHidden = false;
        applicantAuthorsTable.reloadData();
    }
    
    @IBAction func publishButton(_ sender: Any) {
        stateMachine.handle(input: .publish)
        
        if stateMachine.state is PublishingState {
            publishButton.isEnabled = false;
            
            UIView.animate(withDuration: 1, animations: {
                self.timePlayHeadConstraint.constant = self.timelineWidth.constant;
                self.view.layoutIfNeeded();
            }) { (finished) in
                self.sim.publishNextEdition(early: true);

                for i in 0 ..< self.NE_articleTiles.count {
                    self.NE_articleTiles.object(at: i)!.setBlank();
                }
                
                self.updateDataPanels();
            }
        }
    }
}









///////////////////////////////////////////////////////////////////////
///////////////////        Table Methods        ///////////////////////
///////////////////////////////////////////////////////////////////////
extension GameViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == employedAuthorsTable {
            return sim.employedAuthors.count;
        } else if tableView == applicantAuthorsTable {
            return sim.applicantAuthors.count;
        } else if tableView == eventsTable {
            return sim.eventList.count;
        }
        
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == employedAuthorsTable {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "employedAuthorCell", for: indexPath) as? EmployedAuthorCell else {
                fatalError("Employed Author cell downcasting didn't work");
            }
            return cell;
            
        } else if tableView == applicantAuthorsTable {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "applicantAuthorCell", for: indexPath) as? ApplicantAuthorCell else {
                fatalError("Applicant Author cell downcasting didn't work");
            }
            return cell;
            
        } else if tableView == eventsTable {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? EventCell else {
                fatalError("Event cell downcasting didn't work");
            }
            return cell;
        }
        
        return UITableViewCell();
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == employedAuthorsTable {
            let employedCell = cell as! EmployedAuthorCell;
            
            employedCell.authorPortrait.image = sim.employedAuthors[indexPath.row].getPortrait();
            employedCell.authorName.text = sim.employedAuthors[indexPath.row].getName();
            employedCell.level.text = "\(sim.employedAuthors[indexPath.row].getSeniorityLevel())";
            employedCell.morale.text = sim.employedAuthors[indexPath.row].getMoraleSymbol();
            employedCell.morale.textColor = sim.employedAuthors[indexPath.row].getMoraleColor();
            employedCell.publications.text = "\(sim.employedAuthors[indexPath.row].getQuality())";
            employedCell.speed.text = sim.employedAuthors[indexPath.row].getRateSymbol();
            employedCell.salary.text = (sim.employedAuthors[indexPath.row].getSalary() * 365).dollarFormat();
            employedCell.progressConstraint.constant = employedCell.getProgressLength(sim.employedAuthors[indexPath.row].getArticalProgress());
            employedCell.experience.text = Int(sim.employedAuthors[indexPath.row].getExperience()).commaFormat();
            employedCell.skillPoints.text = "\(self.sim.employedAuthors[indexPath.row].getSkillPoints())";
            employedCell.showSkillButtons();
            
            employedCell.topicList.text = "";
            for topic in sim.employedAuthors[indexPath.row].getTopics() {
                employedCell.topicList.text?.append(contentsOf: "\(topic.getApprovalSymbol()) \(topic.getName())\n");
            }
            
            if employedCell.overlayView.isHidden {
                if self.sim.employedAuthors[indexPath.row].getSkillPoints() > 0 {
                    employedCell.overlayButton.setTitleColor(#colorLiteral(red: 0, green: 0.4802635312, blue: 0.9984222054, alpha: 1), for: .normal);
                    employedCell.overlayButton.setTitle("↑", for: .normal)
                    employedCell.overlayButton.titleLabel?.font = UIFont.systemFont(ofSize: 23, weight: .heavy)
                } else {
                    employedCell.overlayButton.setTitleColor(#colorLiteral(red: 0.3601692021, green: 0.3580333591, blue: 0.3618144095, alpha: 1), for: .normal);
                    employedCell.overlayButton.setTitle("⚙︎", for: .normal)
                    employedCell.overlayButton.titleLabel?.font = UIFont.systemFont(ofSize: 23, weight: .regular)
                }
            }
            
            employedCell.toggleOverlay = {
                //Checks for a cell at lastSelectedIndexPath.row which has already shown its overlay
                if self.lastSelectedIndexPath.row != indexPath.row
                && self.lastSelectedIndexPath.row < self.sim.employedAuthors.count {
                    //Returns nil when referenced while scrolled out of sight
                    guard let pCell = tableView.cellForRow(at: self.lastSelectedIndexPath) as? EmployedAuthorCell else { return };
                    pCell.hideOverlay();
                }
                
                self.lastSelectedIndexPath = indexPath;
            }
        
            employedCell.fire = {
                self.sim.fire(authorAt: indexPath.row);
                employedCell.hideOverlay();
                self.lastSelectedIndexPath.row = 0;
                tableView.reloadData();
            }
            
            employedCell.promoteQuality = {
                self.sim.employedAuthors[indexPath.row].promoteQuality();
                employedCell.skillPoints.text = "\(self.sim.employedAuthors[indexPath.row].getSkillPoints())";
                
                employedCell.showSkillButtons();
            }
            
            employedCell.promoteSpeed = {
                self.sim.employedAuthors[indexPath.row].promoteSpeed();
                employedCell.skillPoints.text = "\(self.sim.employedAuthors[indexPath.row].getSkillPoints())";
                
                employedCell.showSkillButtons();
            }
            
        } else if tableView == applicantAuthorsTable {
            let applicantCell = cell as! ApplicantAuthorCell;
            
            applicantCell.authorPortrait.image = sim.applicantAuthors[indexPath.row].getPortrait();
            applicantCell.authorName.text = sim.applicantAuthors[indexPath.row].getName();
            applicantCell.quality.text = "\(sim.applicantAuthors[indexPath.row].getQuality())";
            applicantCell.speed.text = sim.applicantAuthors[indexPath.row].getRateSymbol();
            applicantCell.salary.text = (sim.applicantAuthors[indexPath.row].getSalary() * 365).dollarFormat();
            
            applicantCell.topicList.text = "";
            for topic in sim.applicantAuthors[indexPath.row].getTopics() {
                applicantCell.topicList.text?.append(contentsOf: "\(topic.getApprovalSymbol()) \(topic.getName())\n");
            }
            
            applicantCell.onButtonTapped = {
                self.sim.hire(self.sim.applicantAuthors[indexPath.row]);
                tableView.reloadData();
            }
            
        } else if tableView == eventsTable {
            let eventCell = cell as! EventCell;
            
            eventCell.view.backgroundColor = sim.eventList[indexPath.row].color;
            eventCell.message.text = sim.eventList[indexPath.row].message;
            eventCell.symbol.text = sim.eventList[indexPath.row].symbol;
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("Last selected index: \(lastSelectedIndexPath.row)")
        if scrollView == employedAuthorsTable {
            if employedAuthorsTable.numberOfRows(inSection: 0) > lastSelectedIndexPath.row {
                guard let cell = employedAuthorsTable.cellForRow(at: lastSelectedIndexPath) as? EmployedAuthorCell else {
                    return;
                }
                cell.hideOverlay();
            }
        }
    }
}
