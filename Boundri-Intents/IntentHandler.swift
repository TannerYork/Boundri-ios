//
//  IntentHandler.swift
//  Boundri-Intents
//
//  Created by Tasfia Addrita on 7/29/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import Intents

class ReadTextIntentHandler: NSObject, ReadTextIntentHandling {
    
    func confirm(intent: ReadTextIntent, completion: @escaping (ReadTextIntentResponse) -> Void) {
        completion(ReadTextIntentResponse(code: .ready, userActivity: nil))
    }
    
    func handle(intent: ReadTextIntent, completion: @escaping (ReadTextIntentResponse) -> Void) {
        AppIntent().readTextHandler { (response) in
            completion(.success(textResponse: response))
        }
    }
}

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        guard intent is ReadTextIntent else {
            fatalError("Unhandled intent.")
        }
        return ReadTextIntentHandler()
    }
    
}
