//
//  Company.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 9/24/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import Foundation

class Company {
    private var _funds: Int = 500000;
    private var _yesterdaysProfit: Int = 0;
    private var _commissionsPaid: Int = 0;
    
    //Constants
    private let _OPERATIONS_COSTS: Int = 500;
    private let _SUBSCRIPTION_FEE: Int = 15;
    
    
    //Company tick happens once a day
    func tick(subscribers: Int, employedAuthors: [Author]) {
        _yesterdaysProfit = subscribers * _SUBSCRIPTION_FEE;
        
        for author in employedAuthors {
            _yesterdaysProfit -= author.getSalary();
        }
        
        _yesterdaysProfit -= _commissionsPaid;
        _yesterdaysProfit -= _OPERATIONS_COSTS;
        _funds += _yesterdaysProfit;
        
        _commissionsPaid = 0;
    }
    
    func getFunds() -> Int {
        return _funds;
    }
    
    func getYesterdaysProfit() -> Int {
        return _yesterdaysProfit;
    }
    
    func getOperationsCosts() -> Int {
        return _OPERATIONS_COSTS;
    }
    
    func getSubscriptionFee() -> Int {
        return _SUBSCRIPTION_FEE;
    }
    
    func payCommission(to author: Author) {
        _commissionsPaid += author.getCommission();
    }
}
