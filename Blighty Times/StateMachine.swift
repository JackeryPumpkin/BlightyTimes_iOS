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
        lastState = state
        state = state.handle(input: input) ?? state
    }
}

protocol State {
    func handle(input: Input) -> State?
}

enum Input: String {
    case play = "Play"
    case pause = "Pause"
    case weekend = "Weekend"
    case tutorial = "Tutorial"
    
    case next = "Next"
    case done = "Done"
}
