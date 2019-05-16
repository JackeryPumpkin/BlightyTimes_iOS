//
//  TutorialState.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/4/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import Foundation


class TutorialState: State {
    var pageCount: Int?
    private var currentPage: Int = 1
    
    init() {
        print("[STATE MACHINE]  º TutorialState")
    }
    
    func handle(input: Input, stateObject: StateObject) -> State? {
        if input == .next {
            if let count = pageCount {
                currentPage += 1
                if currentPage > count {
                    return stateObject.stateMachine.lastState
                }
            } else {
                return PlayState()
            }
        }
        
        return nil
    }
    
    func enter(_ stateObject: StateObject) {
        stateObject.stopGameTime()
    }
    
    func render(_ stateObject: StateObject) {
        //
    }
    
    func exit(_ stateObject: StateObject) {
        //
    }
}
