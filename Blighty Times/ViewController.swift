//
//  ViewController.swift
//  BlightyTimes
//
//  Created by Zachary Duncan on 8/15/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //Article Outlets & Properties
    @IBOutlet weak var NE_articleSlotsTop: UIStackView!
    @IBOutlet weak var NE_articleSlotsBottom: UIStackView!
    @IBOutlet weak var NE_bonusTopic: UILabel!
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
    @IBOutlet weak var totalSubscribers: UILabel!
    @IBOutlet weak var newSubscribers: UILabel!
    @IBOutlet var regionBars: [UIView]!
    @IBOutlet var regionBarConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var regionBarsMaxConstraint: NSLayoutConstraint!
    @IBOutlet var regionBarProgressSymbols: [UILabel]!
    
    //Game Properties
    private var sim = Simulation();
    private var gameTimer: Timer!;
    
    //Moving Tile Outlets and Properties
    @IBOutlet weak var movingTileReferenceView: UIView!
    @IBOutlet weak var movingTileTitle: UILabel!
    @IBOutlet weak var movingTileAuthor: UILabel!
    private var movingTileIndex: Int?;
    private var NE_movingTileIndex: Int?;
    private var lastknownTileLocation: CGPoint?;
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        sim.start();
        
        setupAesthetics();
        createTiles();
        startGameTime();
    }
    
    @objc func tick() {
        //Game Simulation
        sim.tick();
        
        //Animate UI changes
        employedAuthorsTable.reloadData();
        dayOfTheWeek.text = sim.getDayOfTheWeek();
        timeOfDay.text = sim.getTimeOfDay();
        timePlayHeadConstraint.constant = sim.getPlayheadLength(maxLength: timelineWidth.constant);
        
        //Cleans up dead articles
        for i in 0 ..< articleTiles.count {
            if let tile = articleTiles.object(at: i) {
                if tile.article.getLifetime() <= 0 {
                    tile.setBlank();
                }
            }
        }
        
        if sim.isEndOfDay() {
            stopGameTime();
            
            for i in 0 ..< self.NE_articleTiles.count {
                self.NE_articleTiles.object(at: i)!.setBlank();
            }
            
            animateDataBars();
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
        
        if sim.writtenArticles.count == 12 { pendingSlotsFullWarning.isHidden = false; }
        else { pendingSlotsFullWarning.isHidden = true; }
        
        //Handles the behavior of the moving tile from pending
        for i in 0 ..< articleTiles.count {
            if articleTiles.object(at: i)!.isTouched {
                movingTileIndex = i;
                
                movingTileTitle.text = articleTiles.object(at: i)!.article.getTitle();
                movingTileAuthor.text = articleTiles.object(at: i)!.article.getAuthor().getName();
                movingTileReferenceView.backgroundColor = articleTiles.object(at: i)!.article.getTopic().getColor();
            }
        }
        
        //Handles the behavior of the moving tile from NE
        for i in 0 ..< NE_articleTiles.count {
            if NE_articleTiles.object(at: i)!.isTouched {
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
                applicantBadgeCooldown = 10;
            }
        } else {
            applicantBadgeCooldown -= 1;
            applicantAuthorsTable.reloadData();
        }
    }
    
    @IBAction func pauseButton(_ sender: Any) {
        sim.pauseplayButtonPressed();
        
        if sim.isPaused() {
            pauseButton.setTitle("▶︎", for: .normal);
            pausesLeft.text = "\(sim.getPausesLeft())";
            stopGameTime();
        } else {
            if sim.getPausesLeft() == 0 {
                pauseButton.setTitle("᰽", for: .normal);
                startGameTime();
                pauseButton.isEnabled = false;
            } else {
                pauseButton.setTitle("||", for: .normal);
                startGameTime();
            }
        }
    }
    
    func startGameTime() {
        gameTimer = Timer.scheduledTimer(timeInterval: Simulation.TICK_RATE, target: self, selector: #selector(tick), userInfo: nil, repeats: true);
    }
    
    func stopGameTime() {
        gameTimer.invalidate();
    }
    
    func createTiles() {
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
        //Dragging for Pending Tiles
        if let index = movingTileIndex {
            if let tile = articleTiles.object(at: index) {
                
                if recognizer.state == .began {
                    tile.layer.opacity = 0;
                    
                    if index < 4 {
                        lastknownTileLocation = CGPoint(x: tile.center.x + 20, y: (articleSlotsStack.frame.maxY - 10) - (articleSlotsTop.frame.height * 2.5));
                    } else if index < 8 {
                        lastknownTileLocation = CGPoint(x: tile.center.x + 20, y: (articleSlotsStack.frame.maxY - 5) - (articleSlotsMiddle.frame.height * 1.5));
                    } else if index < 12 {
                        lastknownTileLocation = CGPoint(x: tile.center.x + 20, y: (articleSlotsStack.frame.maxY) - (articleSlotsBottom.frame.height * 0.5));
                    }
                    
                    movingTileReferenceView.center = lastknownTileLocation!;
                    movingTileReferenceView.isHidden = false;
                }// End .began
                
                
                
                let translation = recognizer.translation(in: self.view);
                movingTileReferenceView.center = CGPoint(x: movingTileReferenceView.center.x + translation.x, y: movingTileReferenceView.center.y + translation.y);
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
                //1. It's in the same spot or another non-blank NE slot
                //2. It's in another blank NE slot
                //3. It's anywhere else and either animates to first available Pending slot or back to its own slot
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
                                        lastknownTileLocation = CGPoint(x: (tile.frame.width * CGFloat(i)) + tile.center.x + 20, y: (articleSlotsStack.frame.maxY - 10) - (articleSlotsTop.frame.height * 2.5));
                                    } else if i < 8 {
                                        lastknownTileLocation = CGPoint(x: (tile.frame.width * CGFloat(i)) + tile.center.x + 20, y: (articleSlotsStack.frame.maxY - 5) - (articleSlotsMiddle.frame.height * 1.5));
                                    } else if i < 12 {
                                        lastknownTileLocation = CGPoint(x: (tile.frame.width * CGFloat(i)) + tile.center.x + 20, y: (articleSlotsStack.frame.maxY) - (articleSlotsBottom.frame.height * 0.5));
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
                    UIView.animate(withDuration: 0.2, animations: {
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
    
    func animateDataBars() {
        stopGameTime();
        
        companyFunds.text = "$\(sim.COMPANY.getFunds())";
        yesterdaysProfit.text = "$\(sim.COMPANY.getYesterdaysProfit())";
        totalSubscribers.text = "\(sim.POPULATION.getTotalSubscriberCount())";
        newSubscribers.text = "\(sim.POPULATION.getNewSubscriberCount())";
        
        for i in 0 ..< self.regionBars.count {
            if self.sim.POPULATION.regions[i].getNewSubscriberCount() > 0 {
                self.regionBars[i].backgroundColor =  #colorLiteral(red: 0.4885490545, green: 0.7245667335, blue: 0.9335739213, alpha: 1);
                self.regionBarProgressSymbols[i].text = ">";
            } else if self.sim.POPULATION.regions[i].getNewSubscriberCount() < 0 {
                self.regionBars[i].backgroundColor = #colorLiteral(red: 0.9179712534, green: 0.522530973, blue: 0.5010649562, alpha: 1);
                self.regionBarProgressSymbols[i].text = "<";
            } else {
                self.regionBars[i].backgroundColor = #colorLiteral(red: 0.7368394732, green: 0.736964643, blue: 0.7368229032, alpha: 1);
                self.regionBarProgressSymbols[i].text = "";
            }
            
            if self.sim.POPULATION.regions[i].getTotalSubscriberCount() == 0 {
                self.regionBarConstraints[i].constant = 0;
            } else {
                self.regionBarConstraints[i].constant = self.regionBarsMaxConstraint.constant * (CGFloat(self.sim.POPULATION.regions[i].getTotalSubscriberCount()) / CGFloat(self.sim.POPULATION.regions[i].getSize()));
            }
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded();
        }) { (finished) in
            self.startGameTime();
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
        stopGameTime();
        
        UIView.animate(withDuration: 1, animations: {
            self.timePlayHeadConstraint.constant = self.timelineWidth.constant;
            self.view.layoutIfNeeded();
        }) { (finished) in
            self.sim.publishNextEdition(is: true);

            for i in 0 ..< self.NE_articleTiles.count {
                self.NE_articleTiles.object(at: i)!.setBlank();
            }
            
            self.animateDataBars();
        }
    }
}









///////////////////////////////////////////////////////////////////////
///////////////////        Table Methods        ///////////////////////
///////////////////////////////////////////////////////////////////////
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == employedAuthorsTable {
            return sim.employedAuthors.count;
            
        } else if tableView == applicantAuthorsTable {
            return sim.applicantAuthors.count;
        }
        
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == employedAuthorsTable {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "employedAuthorCell", for: indexPath) as? EmployedAuthorCell else {
                fatalError("Employed Author cell downcasting didn't work");
            }
            
            cell.authorPortrait.image = sim.employedAuthors[indexPath.row].getPortrait();
            cell.authorName.text = sim.employedAuthors[indexPath.row].getName();
            cell.level.text = "\(sim.employedAuthors[indexPath.row].getSeniorityLevel())";
            cell.morale.text = "\(sim.employedAuthors[indexPath.row].getMoraleSymbol())";
            cell.publications.text = "\(sim.employedAuthors[indexPath.row].getQuality())";
            cell.speed.text = sim.employedAuthors[indexPath.row].getRateSymbol();
            cell.salary.text = "$" + sim.employedAuthors[indexPath.row].getFormattedSalary();
            cell.progressConstraint.constant = cell.getProgressLength(sim.employedAuthors[indexPath.row].getArticalProgress());
            cell.experience.text = "\(Int(sim.employedAuthors[indexPath.row].getExperience()))";
            
            cell.topicList.text = "";
            for topic in sim.employedAuthors[indexPath.row].getTopics() {
                cell.topicList.text?.append(contentsOf: "\(topic.getApprovalSymbol()) \(topic.getName())\n");
            }
            
            return cell;
            
        } else if tableView == applicantAuthorsTable {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "applicantAuthorCell", for: indexPath) as? ApplicantAuthorCell else {
                fatalError("Applicant Author cell downcasting didn't work");
            }
            
            cell.authorPortrait.image = sim.applicantAuthors[indexPath.row].getPortrait();
            cell.authorName.text = sim.applicantAuthors[indexPath.row].getName();
            cell.quality.text = "\(sim.applicantAuthors[indexPath.row].getQuality())";
            cell.speed.text = sim.applicantAuthors[indexPath.row].getRateSymbol();
            cell.salary.text = sim.applicantAuthors[indexPath.row].getFormattedSalary();
            
            cell.topicList.text = "";
            for topic in sim.applicantAuthors[indexPath.row].getTopics() {
                cell.topicList.text?.append(contentsOf: "\(topic.getApprovalSymbol()) \(topic.getName())\n");
            }
            
            cell.onButtonTapped = {
                self.sim.hire(self.sim.applicantAuthors[indexPath.row]);
                tableView.reloadData();
            }
            
            return cell;
        }
        
        return UITableViewCell();
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == employedAuthorsTable {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "employedAuthorCell", for: indexPath) as? EmployedAuthorCell else {
                fatalError("Employed Author cell downcasting didn't work");
            }
            
            cell.overlayView.isHidden = false;
        }
    }
}
