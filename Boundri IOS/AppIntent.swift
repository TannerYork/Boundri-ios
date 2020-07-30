//
//  AppIntent.swift
//  Boundri IOS
//
//  Created by Tasfia Addrita on 7/29/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import Foundation
import Intents

class AppIntent {
    
    // HomeTVC
    // INInteraction(intent: ReadTextIntent(), response: nil).donate(completion: nil)
    
    class func readText() {
        let intent = ReadTextIntent()
        intent.suggestedInvocationPhrase = "Read text"
        
        let interaction = INInteraction(intent: intent, response: nil)
        
        interaction.donate { error in
            if let error = error as NSError? {
                print("Interaction donation failed: \(error.description)")
            } else {
                print("Successfully donated interaction.")
            }
        }
    }
    
    func readTextHandler(handler: @escaping (String) -> Void) {
        return handler("Please work.")
    }
}
