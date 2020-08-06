//
//  VisionOptionsManager.swift
//  Boundri IOS
//
//  Created by Tanner York on 8/4/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import Foundation
import UIKit
import MLKit

//MARK: Vision Options Manager
class ImageProcessor {
    static let shared = ImageProcessor()
    
    func proccess(image: UIImage, with visionOption: ShortcutsManager.Kind, completion: @escaping ([String: String]) -> Void) {
        if visionOption == .openReadText {
            self.readText(in: image) { (results) in
                completion(["output" : results, "phrase" : "Read text in image"])
            }
        } else if visionOption == .openDescribeScene {
            self.describeScene(in: image) { (results) in
                completion(["output" : results, "phrase" : "Describe scene in image"])
            }
        }
    }
    
    func readText(in image: UIImage, completion: @escaping (String) -> Void) {
    
        let visionImage = VisionImage(image: image)
        visionImage.orientation = image.imageOrientation
        
        let textRecognizer = TextRecognizer.textRecognizer()
        textRecognizer.process(visionImage) { result, error in
            guard error == nil, let result = result else { return }
            completion(result.text)
        }
    }
    
    func describeScene(in image: UIImage, completion: @escaping (String) -> Void) {
        completion("To your left there's a Chair, directly ahead of you there's a Television and Person, and to your right there's a Laptop and Computer keyboard.")
    }
}
