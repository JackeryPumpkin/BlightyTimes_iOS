//
//  TutorialState.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 5/4/19.
//  Copyright © 2019 Zachary Duncan. All rights reserved.
//

import Foundation


class TutorialState: State {
    func handle(input: Input) -> State? {
        if input == .done {
            return PlayState()
        }
        
        return nil
    }
}
