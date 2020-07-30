//
//  ReadTextIntentHandler.swift
//  Boundri-Intents
//
//  Created by Tanner York on 7/30/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import Intents
import UIKit
import MLKit

class ReadTextIntentHandler: NSObject, ReadTextIntentHandling {
    
    func confirm(intent: ReadTextIntent, completion: @escaping (ReadTextIntentResponse) -> Void) {
        completion(ReadTextIntentResponse(code: .ready, userActivity: nil))
    }
    
    func handle(intent: ReadTextIntent, completion: @escaping (ReadTextIntentResponse) -> Void) {
        AppIntent().readTextHandler { (response) in
            completion(.success(textResponse: response))
        }
    }
    
    func readTextFromSampleImageHandler(completion: @escaping (String) -> Void) {
//        if let sampleImg = UIImage(named: "sample_img.png") {
//            let visionImage = VisionImage(image: sampleImg)
//            visionImage.orientation = sampleImg.imageOrientation
//
//            let textRecognizer = TextRecognizer.textRecognizer()
//
//            textRecognizer.process(visionImage) { result, error in
//                guard error == nil, let result = result else {
//                    return handler("error")
//                }
//                return handler(result.text)
//            }
//        }

//        let response = INStartWorkoutIntentResponse(code: .continueInApp,
//        userActivity: nil)
        return completion("This is a placeholder responce")

    }
}
