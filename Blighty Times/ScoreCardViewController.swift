//
//  ScoreCardViewController.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 10/22/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import UIKit

class ScoreCardViewController: UIViewController {
    @IBOutlet weak var firstStack: UIStackView!
    @IBOutlet weak var weekNumber: UILabel!
    @IBOutlet weak var paidToEmployees: UILabel!
    @IBOutlet weak var officeCosts: UILabel!
    @IBOutlet weak var earnedRevenue: UILabel!
    @IBOutlet weak var subscriberFluxuation: UILabel!
    
    @IBOutlet weak var secondStack: UIStackView!
    @IBOutlet weak var employeesHired: UILabel!
    @IBOutlet weak var employeesFired: UILabel!
    @IBOutlet weak var promotionsGiven: UILabel!
    @IBOutlet weak var articlesPublished: UILabel!
    @IBOutlet weak var averageQuality: UILabel!
    
    var sim: Simulation?
    var tapCount: Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        guard let sim = sim else { return }
        
        weekNumber.text = "\(sim.getWeekNumber())"
        paidToEmployees.text = sim.company.getPaidToEmployeesThisWeek().dollarFormat()
        officeCosts.text = sim.company.getOfficeCostsThisWeek().dollarFormat()
        earnedRevenue.text = sim.company.getEarnedRevenueThisWeek().dollarFormat()
        subscriberFluxuation.text = sim.population.getSubscriberFluxuationThisWeek().commaFormat()
        
        employeesHired.text = "\(sim.getEmployeesHiredThisWeek())"
        employeesFired.text = "\(sim.getEmployeesFiredThisWeek())"
        promotionsGiven.text = "\(sim.getPromotionsGivenThisWeek())"
        articlesPublished.text = "\(sim.getArticlesPublishedThisWeek())"
        averageQuality.text = "\(sim.getAverageQualityThisWeek())"
        
        view.backgroundColor = .white;
        
        UIView.animate(withDuration: 0.2) {
            self.view.backgroundColor = #colorLiteral(red: 0.2615382373, green: 0.2616910338, blue: 0.315728873, alpha: 1)
            self.firstStack.alpha = 1.0
        }
    }
    
    @IBAction func next(_ sender: Any) {
        if tapCount == 0 {
            tapCount += 1
            
            UIView.animate(withDuration: 0.2, animations: {
                self.firstStack.alpha = 0.0
            }) { (finished) in
                UIView.animate(withDuration: 0.2) {
                    self.secondStack.alpha = 1.0
                }
            }
            
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.secondStack.alpha = 0.0
                self.view.backgroundColor = .white
            }) { (finished) in
                self.performSegue(withIdentifier: "unwindScore", sender: self)
            }
        }
    }
}
