//
//  PausedState.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/4/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import Foundation


class PauseState: State {
    let string = "PauseState"
    
    func handle(input: Input, stateObject: StateObject) -> State? {
        if input == .play || input == .invertPlayPause {
            return PlayState()
        }
        
        return nil
    }
    
    func enter(_ stateObject: StateObject) {
        stateObject.sim.pause()
        stateObject.stopGameTime()
    }
    
    func render(_ stateObject: StateObject) {
        //
    }
    
    func exit(_ stateObject: StateObject) {
        //
    }
}
