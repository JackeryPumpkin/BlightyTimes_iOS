//
//  GameState.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 11/27/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import UIKit


class StateMachine {
    var state: State
    var lastState: State?
    
    init(state: State) {
        self.state = state
    }
    
    func handleInput(input: Input) {
        print("[STATE MACHINE]  > Input: " + input.rawValue)
        lastState = state
        state = state.handle(input: input) ?? state
    }
}

protocol State {
    func handle(input: Input) -> State?
}

enum Input: String {
    case pause = "Pause"
    case publish = "Publish"
    case next = "Next"
    case done = "Done"
    
    case publishComplete = "Publish Complete"
    case weekend = "Weekend"
    case tutorial = "Tutorial"
}
