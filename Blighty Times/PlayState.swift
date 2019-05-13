//
//  PlayState.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/4/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import Foundation


class PlayState: State {
    init() {
        print("[STATE MACHINE]  º PlayState")
    }
    
    func handle(input: Input) -> State? {
        if input == .pause {
            return PauseState()
        } else if input == .publish {
            return PublishingState()
        } else if input == .weekend {
            return InfographicState()
        } else if input == .tutorial {
            return TutorialState()
        }
        
        return nil
    }
}
