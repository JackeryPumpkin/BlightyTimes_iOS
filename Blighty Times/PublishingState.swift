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
    
    func handle(input: Input) -> State? {
        if input == .publishComplete {
            return PlayState()
        }
        
        return nil
    }
}
