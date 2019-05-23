//
//  OfficePurchaseMenu.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/19/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import UIKit

class OfficePurchaseMenu: UIViewController {
    @IBOutlet weak var small: OfficeButton!
    @IBOutlet weak var medium: OfficeButton!
    @IBOutlet weak var large: OfficeButton!
    @IBOutlet weak var huge: OfficeButton!
    @IBOutlet weak var buy: SkillButton!
    
    @IBOutlet weak var available: UILabel!
    @IBOutlet weak var dailyCosts: UILabel!
    @IBOutlet weak var capacity: UILabel!
    @IBOutlet weak var moraleModifier: UILabel!
    @IBOutlet weak var regions: UILabel!
    
    var gameVC: GameViewController?
    var currentOfficeSize: OfficeSize = .small
    
    
    override func viewDidLoad() {
        guard let game = gameVC else { dismiss(animated: true, completion: nil); return }
        
        buy.setTitle("BUY", for: .normal)
        buy.setTitle("PURCHASED", for: .disabled)
        small.purchased = game.sim.officeList[0].purchased
        medium.purchased = game.sim.officeList[1].purchased
        large.purchased = game.sim.officeList[2].purchased
        huge.purchased = game.sim.officeList[3].purchased
        
        updateView(with: .small)
    }
    
    @IBAction func smallOffice(_ sender: Any) {
        updateView(with: .small)
    }
    @IBAction func mediumOffice(_ sender: Any) {
        updateView(with: .medium)
    }
    @IBAction func largeOffice(_ sender: Any) {
        updateView(with: .large)
    }
    @IBAction func hugeOffice(_ sender: Any) {
        updateView(with: .huge)
    }
    
    @IBAction func buyOffice(_ sender: Any) {
        guard let game = gameVC else { print("BUY OFFICE FAILED - COULD NOT LOCATE GAMEVC"); return }
        
        if !game.sim.purchaseOffice(currentOfficeSize) {
            dismiss(animated: true, completion: nil)
        }
        
        updateView(with: currentOfficeSize)
        game.updateOfficeTab()
        game.companyFunds.text = game.sim.company.getFunds().dollarFormat()
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func updateView(with officeSize: OfficeSize) {
        guard let game = gameVC else  { return }
        let office: Office
        
        currentOfficeSize = officeSize
        
        small.isInUse = false
        medium.isInUse = false
        large.isInUse = false
        huge.isInUse = false
        
        switch officeSize {
        case .small:
            office = Office.small()
            small.isInUse = true
        case .medium:
            office = Office.medium()
            medium.isInUse = true
        case .large:
            office = Office.large()
            large.isInUse = true
        case .huge:
            office = Office.huge()
            huge.isInUse = true
        }
        
        buy.isEnabled = false
        
        if game.sim.officeList[officeSize.rawValue].purchased {
            available.text = " "
            buy.setTitle("PURCHASED", for: .disabled)
        } else {
            if game.sim.officeList.indices.contains(officeSize.rawValue - 1) {
                if game.sim.officeList[officeSize.rawValue - 1].purchased {
                    available.text = office.downPayment.dollarFormat()
                    buy.isEnabled = true
                } else {
                    available.text = "UNAVAILABLE"
                    buy.setTitle("BUY", for: .disabled)
                }
            }
        }
        
        dailyCosts.text = office.dailyCosts.dollarFormat()
        capacity.text = "\(office.capacity)"
        regions.text = "\(office.regionCount)"
        moraleModifier.text = office.moraleModifierSymbol
    }
}
