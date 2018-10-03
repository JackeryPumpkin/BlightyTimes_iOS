//
//  ViewController.swift
//  BlightyTimes
//
//  Created by Zachary Duncan on 8/15/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //Article Outlets & Properties
    @IBOutlet weak var pendingSlotsFullWarning: UILabel!
    @IBOutlet weak var articleSlotsStack: UIStackView!
    @IBOutlet weak var articleSlotsTop: UIStackView!
    @IBOutlet weak var articleSlotsMiddle: UIStackView!
    @IBOutlet weak var articleSlotsBottom: UIStackView!
    @IBOutlet weak var articleTileHight: NSLayoutConstraint!
    
    var articleTiles: NSPointerArray = .weakObjects();
    
    @IBOutlet weak var employedAuthorsTable: UITableView!;
    @IBOutlet weak var dayOfTheWeek: UILabel!
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
    private var lastknownTileLocation: CGPoint = CGPoint();
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        setupAesthetics();
        
        sim.start();
        
        createTiles();
        
        gameTimer = Timer.scheduledTimer(timeInterval: Simulation.TICK_RATE, target: self, selector: #selector(tick), userInfo: nil, repeats: true);
    }
    
    @objc func tick() {
        //Game Simulation
        sim.tick();
        
        //Animate UI changes
        employedAuthorsTable.reloadData();
        dayOfTheWeek.text = sim.getDayOfTheWeek();
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
        a: for article in sim.newArticles {
            b: for i in 0 ..< articleTiles.count {
                if let tile = articleTiles.object(at: i) {
                    if tile.article.getTitle() == ArticleLibrary.blank.getTitle() {
                        tile.set(article: article);
                        
                        break b;
                    }
                }
            }
        }
        
        sim.syncNewArticles();
        
        if sim.writtenArticles.count == 12 { pendingSlotsFullWarning.isHidden = false; }
        else { pendingSlotsFullWarning.isHidden = true; }
        
        if movingTileIndex == nil {
            for i in 0 ..< articleTiles.count {
                if articleTiles.object(at: i)!.isTouched {
                    movingTileIndex = i;

                    movingTileTitle.text = articleTiles.object(at: i)!.article.getTitle();
                    movingTileAuthor.text = articleTiles.object(at: i)!.article.getAuthor().getName();
                    movingTileReferenceView.backgroundColor = articleTiles.object(at: i)!.article.getTopic().getColor();
                }
            }
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sim.employedAuthors.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "employedAuthorCell", for: indexPath) as? EmployedAuthorCell else {
            fatalError("Employed Author cell downcasting didn't work");
        }
        
        cell.authorPortrait.image = sim.employedAuthors[indexPath.row].getPortrait();
        cell.authorName.text = sim.employedAuthors[indexPath.row].getName();
        cell.level.text = "\(sim.employedAuthors[indexPath.row].getSeniorityLevel())";
        cell.morale.text = "\(sim.employedAuthors[indexPath.row].getMoraleSymbol())";
        cell.publications.text = "\(sim.employedAuthors[indexPath.row].getSubmittedThisWeek())";
        cell.speed.text = sim.employedAuthors[indexPath.row].getRateSymbol();
        cell.salary.text = "$\(sim.employedAuthors[indexPath.row].getSalary())";
        cell.progressConstraint.constant = cell.getProgressLength(sim.employedAuthors[indexPath.row].getArticalProgress());
        cell.experience.text = "\(Int(sim.employedAuthors[indexPath.row].getExperience()))";
        
        cell.topicList.text = "";
        for topic in sim.employedAuthors[indexPath.row].getTopics() {
            cell.topicList.text?.append(contentsOf: "\(topic.getApprovalSymbol())\(topic.getName())\n");
        }
        
        return cell;
    }
    
    func createTiles() {
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
                        lastknownTileLocation = CGPoint(x: tile.center.x + 20, y: articleSlotsStack.frame.minY + articleSlotsTop.frame.height / 2);
                    } else if index < 8 {
                        lastknownTileLocation = CGPoint(x: tile.center.x + 20, y: articleSlotsStack.frame.midY);
                    } else if index < 12 {
                        lastknownTileLocation = CGPoint(x: tile.center.x + 20, y: articleSlotsStack.frame.maxY - articleSlotsBottom.frame.height / 2);
                    }
                    movingTileReferenceView.center = lastknownTileLocation;
                    movingTileReferenceView.isHidden = false;
                }
                
                if tile.article.getTitle() == ArticleLibrary.blank.getTitle() {
                    recognizer.state = .ended;
                }
                
                let translation = recognizer.translation(in: self.view);
                
                movingTileReferenceView.center = CGPoint(x: movingTileReferenceView.center.x + translation.x,
                                                         y: movingTileReferenceView.center.y + translation.y);
                
                recognizer.setTranslation(CGPoint.zero, in: self.view);
                
                if recognizer.state == .ended || recognizer.state == .cancelled {
                    //Animate movingTileReferenceView back to lastknownTileLocation
                    UIView.animate(withDuration: 0.2, animations: {
                        self.movingTileReferenceView.center = self.lastknownTileLocation;
                    }) { (finished) in
                        tile.layer.opacity = 1;
                        self.movingTileIndex = nil;
                        self.movingTileReferenceView.isHidden = true;
                    }
                }
            }
        }
    }
}

