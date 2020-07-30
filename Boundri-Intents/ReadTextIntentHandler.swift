//
//  ReadTextIntentHandler.swift
//  Boundri-Intents
//
//  Created by Tanner York on 7/21/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import Foundation
import Intents
import MLKit


class ReadTextIntentHandler: NSObject, ReadTextIntentHandling {

    func confirm(intent: ReadTextIntent, completion: @escaping (ReadTextIntentResponse) -> Void) {
        completion(ReadTextIntentResponse(code: .ready, userActivity: nil))
    }
    
    func handle(intent: ReadTextIntent, completion: @escaping (ReadTextIntentResponse) -> Void) {
        let text = analyzeImage()
//        completion(ReadTextIntentResponse.success(textResponse: text))
        completion(.success(textResponse: "I work"))
    }


    func analyzeImage() -> String {
        // Here we need to have a module that takes an image and then pass that image to the API or Cocopods and finally return the string of text the two return
        // In order to connect the camera module, we need to create a module that just takes a photo and then set it's target membership in the right sidebar to both the IOS app and the Intents app targets
        return "Placeholder"
    }
}
