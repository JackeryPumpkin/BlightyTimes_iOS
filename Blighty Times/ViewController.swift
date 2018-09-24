//
//  ViewController.swift
//  BlightyTimes
//
//  Created by Zachary Duncan on 8/15/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var articleSlotsTop: UIStackView!
    @IBOutlet weak var articleSlotsMiddle: UIStackView!
    @IBOutlet weak var articleSlotsBottom: UIStackView!
    @IBOutlet weak var articleTileHight: NSLayoutConstraint!
    
    var articleTiles: NSPointerArray = .weakObjects();
    
    @IBOutlet weak var employedAuthorsTable: UITableView!;
    @IBOutlet weak var dayOfTheWeek: UILabel!
    @IBOutlet weak var pausesLeft: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    
    private var sim = Simulation();
    private var gameTimer: Timer!;
    
    
    override func viewDidLoad() {
        //print("viewDidLoad");
        super.viewDidLoad();
        
        sim.spawnFirstAuthor();
        createTiles();
        
        gameTimer = Timer.scheduledTimer(timeInterval: Simulation.TICK_RATE, target: self, selector: #selector(tick), userInfo: nil, repeats: true);
    }
    
    @objc func tick() {
        //User Interactions
        
        //Game Simulation
        sim.tick();
        
        //Animate UI changes
        employedAuthorsTable.reloadData();
        dayOfTheWeek.text = sim.getDayOfTheWeek();
        
        //All articles are put to end of a queue, including re-queued
        //If an article is currently being touched, it is considered by the model to be in writtenArticles
        
        //Cleans up dead articles
        for i in 0 ..< articleTiles.count {
            if let tile = articleTiles.object(at: i) as? ArticleTile {
                if tile.article.getLifetime() < 1.0 {
                    tile.setBlank();
                }
            }
        }
        
        //Adds in new articles
        a: for article in sim.newArticles {
            b: for i in 0 ..< articleTiles.count {
                if let tile = articleTiles.object(at: i) as? ArticleTile {
                    if tile.article.getTitle() == ArticleLibrary.blank.getTitle() {
                        tile.set(article: article);
                        
                        break b;
                    }
                }
            }
        }
        
        sim.syncNewArticles();
    }
    
    @IBAction func pauseButton(_ sender: Any) {
        sim.pauseplayButtonPressed();
        
        if sim.isPaused() {
            pauseButton.titleLabel?.text = "►";
            pausesLeft.text = "\(sim.getPausesLeft())";
            gameTimer.invalidate();
        } else {
            pauseButton.titleLabel?.text = "||";
            gameTimer = Timer.scheduledTimer(timeInterval: Simulation.TICK_RATE, target: self, selector: #selector(tick), userInfo: nil, repeats: true);
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("numberOfRowsInSection");
        return sim.employedAuthors.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt: \(indexPath.row)");
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "employedAuthorCell", for: indexPath) as? EmployedAuthorCell else {
            fatalError("Employed Author cell downcasting didn't work");
        }
        
        cell.authorPortrait.image = sim.employedAuthors[indexPath.row].getPortrait();
        cell.authorName.text = sim.employedAuthors[indexPath.row].getName();
        cell.authorTitle.text = sim.employedAuthors[indexPath.row].getTitle();
        cell.authorBonus.text = sim.employedAuthors[indexPath.row].getBonus();
        
//        cell.authorProgress.alpha = CGFloat(gameService.employedAuthors[indexPath.row].getArticalProgress()) / 100;
        cell.authorProgress.text = "\(sim.employedAuthors[indexPath.row].getArticalProgress())%";
        cell.authorBonus.text = "Morale: \(sim.employedAuthors[indexPath.row].getMorale())";
        
        return cell;
    }
    
    func createTiles() {
        for i in 1 ... 12 {
            guard let tile = Bundle.main.loadNibNamed("ArticleTile", owner: self, options: nil)?.first as? ArticleTile else { return }
            
            tile.setBlank();
            tile.addConstraint(NSLayoutConstraint(item: tile, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: articleTileHight.constant));
            
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
}

