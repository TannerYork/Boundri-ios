//
//  IntentHandler.swift
//  Boundri-Intents
//
//  Created by Tasfia Addrita on 7/30/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import Intents
import MLKit

class ReadTextIntentHandler: NSObject, ReadTextIntentHandling {
    
    func confirm(intent: ReadTextIntent, completion: @escaping (ReadTextIntentResponse) -> Void) {
        completion(ReadTextIntentResponse(code: .ready, userActivity: nil))
    }
    
    func handle(intent: ReadTextIntent, completion: @escaping (ReadTextIntentResponse) -> Void) {
//        AppIntent().readTextHandler { (response) in
        readTextFromSampleImage { (response) in
            completion(.success(textResponse: response))
        }
    }
    
    func readTextFromSampleImage(handler: @escaping (String) -> Void) {
        // let img = #imageLiteral(resourceName: "sample_img")
        let imageURL = URL(string: "https://d2jaiao3zdxbzm.cloudfront.net/wp-content/uploads/figure-65.png")!
        
        if let imageData = try? Data(contentsOf: imageURL) {
            let img = UIImage(data: imageData)!
            
            let visionImage = VisionImage(image: img)
            visionImage.orientation = img.imageOrientation
            
            let textRecognizer = TextRecognizer.textRecognizer()
            
            textRecognizer.process(visionImage) { result, error in
                guard error == nil, let result = result else {
                    return handler("Error")
                }
                return handler(result.text)
            }
        }
    }
}

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        guard intent is ReadTextIntent else {
            fatalError("Unhandled error.")
        }
        return ReadTextIntentHandler()
    }
}
