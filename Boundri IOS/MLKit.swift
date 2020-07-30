//
//  MLKit.swift
//  Boundri IOS
//
//  Created by Tasfia Addrita on 7/30/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import Foundation
import Intents
import MLKit

public func ocr(handler: @escaping (String) -> Void) {
    if let sampleImg = UIImage(named: "sample_img.png") {
        let visionImage = VisionImage(image: sampleImg)
        visionImage.orientation = sampleImg.imageOrientation
        
        let textRecognizer = TextRecognizer.textRecognizer()
        
        textRecognizer.process(visionImage) { result, error in
            guard error == nil, let result = result else {
                return handler("error")
            }
            return handler(result.text)
        }
    }
}
