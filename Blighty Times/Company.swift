//
//  Company.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 9/24/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import Foundation

class Company {
    private var _funds: Int
    private var _yesterdaysProfit: Int = 0;
    private var _commissionsPaid: Int = 0;
    private var _officeCostsToday: Int = 0;
    
    private var _paidToEmployeesThisWeek: Int = 0;
    private var _earnedRevenueThisWeek: Int = 0;
    private var _officeCostsThisWeek: Int = 0;
    private var _operationalCosts: Int = 1500;
    
    //Constants
    private let _SUBSCRIPTION_FEE: Double = 0.05;
    
    convenience init() {
        self.init(startingFunds: 50000)
    }
    
    init(startingFunds: Int) {
        _funds = startingFunds
    }
    
    //Company tick happens once a day
    func tick(subscribers: Int, employedAuthors: [Author], officeDailyCosts: Int) {
        _yesterdaysProfit = Int(Double(subscribers) * _SUBSCRIPTION_FEE);
        
        for author in employedAuthors {
            _yesterdaysProfit -= author.getSalary();
            _paidToEmployeesThisWeek += author.getSalary();
        }
        
        _yesterdaysProfit -= _commissionsPaid;
        _yesterdaysProfit -= _operationalCosts;
        _yesterdaysProfit -= officeDailyCosts
        _yesterdaysProfit -= _officeCostsToday
        _funds += _yesterdaysProfit;
        _earnedRevenueThisWeek += _yesterdaysProfit;
        _officeCostsThisWeek += officeDailyCosts + _operationalCosts
        
        _officeCostsToday = 0
        _commissionsPaid = 0;
        _operationalCosts = employedAuthors.count * 1500
    }
    
    func getFunds() -> Int {
        return _funds;
    }
    
    func getYesterdaysProfit() -> Int {
        return _yesterdaysProfit;
    }
    
    func getOperationsCosts() -> Int {
        return _operationalCosts;
    }
    
    func getSubscriptionFee() -> Double {
        return _SUBSCRIPTION_FEE;
    }
    
    func getPaidToEmployeesThisWeek() -> Int {
        return _paidToEmployeesThisWeek;
    }
    
    func getEarnedRevenueThisWeek() -> Int {
        return _earnedRevenueThisWeek;
    }
    
    func getOfficeCostsThisWeek() -> Int {
        return _officeCostsThisWeek
    }
    
    func weeklyReset() {
        _paidToEmployeesThisWeek = 0
        _earnedRevenueThisWeek = 0
        _officeCostsThisWeek = 0
    }
    
    func payCommission(to author: Author) {
        _commissionsPaid += author.getCommission();
        _paidToEmployeesThisWeek += author.getCommission();
    }
    
    func payOfficeDownPayment(size: OfficeSize) {
        let costs = Office(size: size).downPayment
        
        _funds -= costs
        _officeCostsThisWeek += costs
        _officeCostsToday += costs
    }
}
