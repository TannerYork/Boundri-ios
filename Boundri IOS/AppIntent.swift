//
//  AppIntent.swift
//  Boundri IOS
//
//  Created by Tasfia Addrita on 7/30/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import Foundation
import MLKit

class AppIntent {
    func readTextHandler(handler: @escaping (String) -> Void) {
        return handler("please work for the love of god")
    }
    
    func readTextFromSampleImage(handler: @escaping (String) -> Void) {
        let img = #imageLiteral(resourceName: "sample_img")
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
