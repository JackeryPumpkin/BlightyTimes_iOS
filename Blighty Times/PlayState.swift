//
//  PlayState.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/4/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import Foundation


class PlayState: State {
    let string = "PlayState"
    
    func handle(input: Input, stateObject: StateObject) -> State? {
        if input == .pause || input == .invertPlayPause {
            if stateObject.sim.getPausesLeft() > 0 {
                return PauseState()
            }
        } else if input == .publish {
            return PublishingState()
        } else if input == .weekend {
            return WeekendState()
        } else if input == .tutorial {
            return TutorialState()
        }
        
        return nil
    }
    
    func enter(_ stateObject: StateObject) {
        stateObject.startGameTime()
    }
    
    func render(_ stateObject: StateObject) {
        //
    }
    
    func exit(_ stateObject: StateObject) {
        //
    }
}
