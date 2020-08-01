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

class OpenReadTextCameraIntentHandler: NSObject, OpenReadTextCameraIntentHandling {
    
    func confirm(intent: OpenReadTextCameraIntent, completion: @escaping (OpenReadTextCameraIntentResponse) -> Void) {
        completion(OpenReadTextCameraIntentResponse(code: .ready, userActivity: nil))
    }
    
    func handle(intent: OpenReadTextCameraIntent, completion: @escaping (OpenReadTextCameraIntentResponse) -> Void) {
        let activity  = NSUserActivity(activityType: "OpenReadTextCameraIntent")
        completion(OpenReadTextCameraIntentResponse(code: .continueInApp, userActivity: activity))
    }

}

class OpenDetectObjectCameraIntentHandler: NSObject, OpenDetectObjectCameraIntentHandling {
    func confirm(intent: OpenDetectObjectCameraIntent, completion: @escaping (OpenDetectObjectCameraIntentResponse) -> Void) {
        completion(OpenDetectObjectCameraIntentResponse(code: .ready, userActivity: nil))
    }

    func handle(intent: OpenDetectObjectCameraIntent, completion: @escaping (OpenDetectObjectCameraIntentResponse) -> Void) {
        let activity  = NSUserActivity(activityType: "OpenDetectObjectCameraIntent")
        completion(OpenDetectObjectCameraIntentResponse(code: .continueInApp, userActivity: activity))
    }
}

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        switch  intent {
        case is ReadTextIntent:
            return ReadTextIntentHandler()
        case is OpenReadTextCameraIntent:
            return OpenReadTextCameraIntentHandler()
        case is OpenDetectObjectCameraIntent:
            return OpenDetectObjectCameraIntentHandler()
        default:
            fatalError()
        }
    }
}
