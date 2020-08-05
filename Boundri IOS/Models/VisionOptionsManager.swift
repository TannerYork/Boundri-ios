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

//MARK: Vision Option
enum VisionOptionType {
    case readText
    case describeScene
}

struct VisionOption {
    let type: VisionOptionType!
    let name: String!
    let details: String!
    let icon: String!
}

//MARK: Vision Options Manager
class VisionOptionsManager {
    static let shared = VisionOptionsManager()
    let defaults = UserDefaults.standard
    
    var activeOptions: [String] = []
    var inactiveOptions: [String] = []
    var avalibleOptions: [VisionOption] = [
        VisionOption(type: .readText, name: "Read Text", details: "Reads any text in the captured image.", icon: "doc.text"),
        VisionOption(type: .describeScene, name: "Describe Scene", details: "Tells you what is happening in the captured image.", icon: "keyboard")
    ]
    
    init() {
        activeOptions = defaults.object(forKey: "avalibleOptions") as? [String] ?? [String]()
        inactiveOptions = defaults.object(forKey: "inactiveOptions") as? [String] ?? [String]()
    }
    
    func saveOptions() {
        defaults.set(avalibleOptions, forKey: "avalibleOptions")
        defaults.set(inactiveOptions, forKey: "inactiveOptions")
    }
    
    func proccess(image: UIImage, with visionOption: VisionOptionType, completion: @escaping ([String: String]) -> Void) {
        if visionOption == .readText {
            self.readText(in: image) { (results) in
                completion(["output" : results, "phrase" : "Read text in image"])
            }
        } else if visionOption == .describeScene {
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
