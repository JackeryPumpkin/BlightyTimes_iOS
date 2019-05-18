//
//  PublishingState.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/5/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import Foundation


class PublishingState: State {
    init() {
        print("[STATE MACHINE]  º PublishingState")
    }
    
    func handle(input: Input, stateObject: StateObject) -> State? {
        if input == .publishComplete {
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
