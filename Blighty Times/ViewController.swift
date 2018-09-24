//
//  ViewController.swift
//  BlightyTimes
//
//  Created by Zachary Duncan on 8/15/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var testTileTitle: UILabel!
    @IBOutlet weak var testTileAuthor: UILabel!
    @IBOutlet weak var testTile: UIView!
    
    
    @IBOutlet var pArticleTileSlots: [UIView]!
    var pArticleSlotStatus: [Bool] = Array(repeating: false, count: 12);
    
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
        
//        for tile in writtenArticleTiles {
//            tile.articleTitle.text = "Fucking Title";
//            tile.authorName.text = "Gatdamn Author";
//            tile.backgroundColor = .red;
//        }
        
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
        
//        a: for article in sim.newArticles {
//            b: for i in 0 ..< writtenArticleTiles.count {
//                if writtenArticleTiles[i].article === ArticleLibrary.blank {
//                    writtenArticleTiles[i].article = article;
//                    writtenArticleTiles[i].articleTitle.text = article.getTitle();
//                    writtenArticleTiles[i].authorName.text = article.getAuthor().getName();
//                    writtenArticleTiles[i].tile.backgroundColor = article.getTopic().getColor();
//
//                    break b;
//                }
//            }
//        }
        
        sim.syncNewArticles();
        
        if !sim.writtenArticles.isEmpty {
            testTileTitle.text = sim.writtenArticles.last!.getTitle();
            testTileAuthor.text = sim.writtenArticles.last!.getAuthor().getName();
            testTile.backgroundColor = sim.writtenArticles.last!.getTopic().getColor();
        }
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
}

