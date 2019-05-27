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
    var lastState: State
    private let stateObject: StateObject
    
    init(state: State, stateObject: StateObject) {
        self.state = state
        self.lastState = state
        self.stateObject = stateObject
        
        self.state.enter(stateObject)
        self.state.render(stateObject)
    }
    
    func handle(input: Input) {
        print("[STATE MACHINE]  > Input: " + input.rawValue)
        
        let newState = state.handle(input: input, stateObject: stateObject)
        
        if let newState = newState {
            print("[STATE MACHINE]  ⦿ State: " + newState.string)
            
            setLastState(state)
            state.exit(stateObject)
            state = newState
            state.enter(stateObject)
        }
        
        state.render(stateObject)
    }
    
    func toLastState() {
        print("[STATE MACHINE]  > toLast  ⦿ State: " + lastState.string)
        
        state.exit(stateObject)
        state = lastState
        state.enter(stateObject)
        state.render(stateObject)
    }
    
    func force(_ newState: State) {
        print("[STATE MACHINE]  > force  ⦿ State: " + newState.string)
        
        setLastState(state)
        state.exit(stateObject)
        state = newState
        state.enter(stateObject)
        state.render(stateObject)
    }
    
    private func setLastState(_ state: State) {
        if state is PlayState || state is PauseState {
            lastState = state
        }
    }
}

protocol State {
    func handle(input: Input, stateObject: StateObject) -> State?
    func enter(_ stateObject: StateObject)
    func render(_ stateObject: StateObject)
    func exit(_ stateObject: StateObject)
    
    var string: String { get }
}

enum Input: String {
    case invertPlayPause = "Invert Play/Pause"
    case pause = "Pause"
    case play = "Play"
    case publish = "Publish"
    case next = "Next"
    case done = "Done"
    
    case publishComplete = "Publish Complete"
    case weekend = "Weekend"
    case offices = "Offices"
    case tutorial = "Tutorial"
}

protocol StateObject {
    var stateMachine: StateMachine! { get set }
    var sim: Simulation { get }
    
    func startGameTime()
    func stopGameTime()
    
    func performSegue(withIdentifier: String, sender: Any?)
}
