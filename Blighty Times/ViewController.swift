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
    @IBOutlet weak var journalistsTitle: UILabel!
    var applicantBadgeCooldown: Int = 0;
    
    @IBOutlet weak var dayOfTheWeek: UILabel!
    @IBOutlet weak var timeOfDay: UILabel!
    @IBOutlet weak var timelineWidth: NSLayoutConstraint!
    @IBOutlet weak var timePlayHeadConstraint: NSLayoutConstraint!
    @IBOutlet weak var pausesLeft: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    
    //Company Outlets
    @IBOutlet weak var companyFunds: UILabel!
    @IBOutlet weak var yesterdaysProfit: UILabel!
    @IBOutlet weak var totalSubscribers: UILabel!
    @IBOutlet weak var newSubscribers: UILabel!
    
    //Game Properties
    private var sim = Simulation();
    private var gameTimer: Timer!;
    
    //Moving Tile Outlets and Properties
    @IBOutlet weak var movingTileReferenceView: UIView!
    @IBOutlet weak var movingTileTitle: UILabel!
    @IBOutlet weak var movingTileAuthor: UILabel!
    private var movingTileIndex: Int?
    private var lastknownTileLocation: CGPoint?;
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        setupAesthetics();
        sim.start();
        createTiles();
        
        gameTimer = Timer.scheduledTimer(timeInterval: Simulation.TICK_RATE, target: self, selector: #selector(tick), userInfo: nil, repeats: true);
        
        sim.spawnApplicant();
    }
    
    @objc func tick() {
        //Game Simulation
        sim.tick();
        
        //Animate UI changes
        employedAuthorsTable.reloadData();
        dayOfTheWeek.text = sim.getDayOfTheWeek();
        timeOfDay.text = sim.getTimeOfDay();
        timePlayHeadConstraint.constant = sim.getPlayheadLength(maxLength: timelineWidth.constant);
        companyFunds.text = "$\(sim.company.getFunds())";
        yesterdaysProfit.text = "$\(sim.company.getYesterdaysProfit())";
        totalSubscribers.text = "\(1000)";
        newSubscribers.text = "0";
        
        //Cleans up dead articles
        for i in 0 ..< articleTiles.count {
            if let tile = articleTiles.object(at: i) {
                if tile.article.getLifetime() <= 0 {
                    tile.setBlank();
                }
            }
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
        
        
        //Handles the Applicants counter visibility
        if applicantBadgeCooldown == 0 {
            if sim.applicantAuthors.count > 0 && applicantsButton.titleLabel?.text == "APPLICANTS" {
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
            gameTimer.invalidate();
        } else {
            if sim.getPausesLeft() == 0 {
                pauseButton.setTitle("᰽", for: .normal);
                gameTimer = Timer.scheduledTimer(timeInterval: Simulation.TICK_RATE, target: self, selector: #selector(tick), userInfo: nil, repeats: true);
                pauseButton.isEnabled = false;
            } else {
                pauseButton.setTitle("||", for: .normal);
                gameTimer = Timer.scheduledTimer(timeInterval: Simulation.TICK_RATE, target: self, selector: #selector(tick), userInfo: nil, repeats: true);
            }
        }
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
        movingTileReferenceView.addShadow(alpha: 0.2, radius: 7, height: 8);
        applicantsCountBadge.roundCorners(withIntensity: .full);
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
                
                
                
                if tile.article.getTitle() == ArticleLibrary.blank.getTitle() {
                    recognizer.state = .ended;
                    (recognizer.view as! ArticleTile).isTouched = false;
                    movingTileIndex = nil;
                }
                let translation = recognizer.translation(in: self.view);
                movingTileReferenceView.center = CGPoint(x: movingTileReferenceView.center.x + translation.x, y: movingTileReferenceView.center.y + translation.y);
                recognizer.setTranslation(CGPoint.zero, in: self.view);
                
                
                
                if recognizer.state == .ended || recognizer.state == .cancelled {
                    let dropLocation = recognizer.location(in: articlePane);
                    var NE_newLocation: CGPoint? = nil;
                    var NE_newIndex: Int? = nil;
                    
                    hitLoop: for ne_view in NE_viewPositions {
                        if dropLocation.x > ne_view.frame.minX &&
                            dropLocation.y > ne_view.frame.minY &&
                            dropLocation.x < ne_view.frame.maxX &&
                            dropLocation.y < ne_view.frame.maxY {
                            
                            if sim.addToNextEdition(article: &tile.article, index: ne_view.tag) {
                                NE_newLocation = ne_view.center;
                                NE_newIndex = ne_view.tag;
                                lastknownTileLocation = nil;
                                
                                NE_articleTiles.object(at: ne_view.tag)?.set(article: &sim._nextEditionArticles[ne_view.tag]);
                            }
                            
                            break hitLoop;
                        }
                    }
                    
                    //Animate movingTileReferenceView back to its destination
                    UIView.animate(withDuration: 0.2, animations: {
                        self.movingTileReferenceView.center = NE_newLocation != nil ? NE_newLocation! : self.lastknownTileLocation!;
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
        }
    }
    
    @IBAction func applicantsButton(_ sender: Any) {
        let APPLICANTS = " Job Applicants";
        let EMPLOYED = " Journalists";
        
        applicantsCountBadge.isHidden = true;
        applicantBadgeCooldown = 10
        
        if journalistsTitle.text == EMPLOYED {
            journalistsTitle.text = APPLICANTS;
            applicantsButton.setTitle("↩︎ BACK", for: .normal);
            applicantsButton.contentHorizontalAlignment = .right;
            applicantsButton.setTitleColor(#colorLiteral(red: 0.8795482516, green: 0.1792428792, blue: 0.3018780947, alpha: 1), for: .normal);
            applicantsButton.backgroundColor = .clear;
            applicantAuthorsTable.isHidden = false;
            
            applicantAuthorsTable.reloadData();
        } else {
            journalistsTitle.text = EMPLOYED;
            applicantsButton.setTitle("APPLICANTS", for: .normal);
            applicantsButton.contentHorizontalAlignment = .center;
            applicantsButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal);
            applicantsButton.backgroundColor = #colorLiteral(red: 0.8795482516, green: 0.1792428792, blue: 0.3018780947, alpha: 1);
            applicantAuthorsTable.isHidden = true;
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
}
