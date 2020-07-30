//
//  IntentHandler.swift
//  Boundri-Intents
//
//  Created by Tasfia Addrita on 7/29/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        guard intent is ReadTextIntent else {
            fatalError("Unhandled intent.")
        }
        return ReadTextIntentHandler()
    }
    
}
