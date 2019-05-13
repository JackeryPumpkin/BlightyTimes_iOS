//
//  PausedState.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/4/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import Foundation


class PauseState: State {
    init() {
        print("[STATE MACHINE]  º PausedState")
    }
    
    func handle(input: Input) -> State? {
        if input == .pause {
            return PlayState()
        }
        
        return nil
    }
}
