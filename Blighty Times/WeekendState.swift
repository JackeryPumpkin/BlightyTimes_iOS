//
//  InfographicState.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/4/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import Foundation


class WeekendState: State {
    init() {
        print("[STATE MACHINE]  º WeekendState")
    }
    
    func handle(input: Input, stateObject: StateObject) -> State? {
        if input == .play {
            return PlayState()
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
