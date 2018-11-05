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
    @IBOutlet weak var earnedRevenue: UILabel!
    @IBOutlet weak var subscriberFluxuation: UILabel!
    
    @IBOutlet weak var secondStack: UIStackView!
    @IBOutlet weak var employeesHired: UILabel!
    @IBOutlet weak var employeesFired: UILabel!
    @IBOutlet weak var promotionsGiven: UILabel!
    @IBOutlet weak var articlesPublished: UILabel!
    @IBOutlet weak var averageQuality: UILabel!
    
    var iweekNumber: Int = 0;
    var ipaidToEmployees: Int = 0;
    var iearnedRevenue: Int = 0;
    var isubscriberFluxuation: Int = 0;
    
    var iemployeesHired: Int = 0;
    var iemployeesFired: Int = 0;
    var ipromotionsGiven: Int = 0;
    var iarticlesPublished: Int = 0;
    var iaverageQuality: Int = 0;
    
    var tapCount: Int = 0;
    
    
    override func viewWillAppear(_ animated: Bool) {
        weekNumber.text = "\(iweekNumber)";
        paidToEmployees.text = ipaidToEmployees.dollarFormat();
        earnedRevenue.text = iearnedRevenue.dollarFormat();
        subscriberFluxuation.text = isubscriberFluxuation.commaFormat();
        
        employeesHired.text = "\(iemployeesHired)";
        employeesFired.text = "\(iemployeesFired)";
        promotionsGiven.text = "\(ipromotionsGiven)";
        articlesPublished.text = "\(iarticlesPublished)";
        averageQuality.text = "\(iaverageQuality)";
    }
    
    @IBAction func next(_ sender: Any) {
        if tapCount == 0 {
            tapCount += 1;
            
            UIView.animate(withDuration: 0.2, animations: {
                self.firstStack.alpha = 0.0;
            }) { (finished) in
                UIView.animate(withDuration: 0.2) {
                    self.secondStack.alpha = 1.0;
                }
            }
            
        } else {
            performSegue(withIdentifier: "unwindScore", sender: self);
        }
    }
}
