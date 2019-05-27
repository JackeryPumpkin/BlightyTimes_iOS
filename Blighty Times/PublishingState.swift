//
//  PublishingState.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/5/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import Foundation


class PublishingState: State {
    let string = "PublishingState"
    
    func handle(input: Input, stateObject: StateObject) -> State? {
        if input == .publishComplete {
            return PlayState()
        } else if input == .weekend {
            return WeekendState()
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
