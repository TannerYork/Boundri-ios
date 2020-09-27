//
//  SpeechSynthesizer.swift
//  Boundri IOS
//
//  Created by Tanner York on 9/26/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import Foundation
import AVFoundation

class SpeechSythesizer {
    static var shared = SpeechSythesizer()
    let sythesizer = AVSpeechSynthesizer()
}

extension SpeechSythesizer {
    
    func stopSpeaking() {
        sythesizer.stopSpeaking(at: .immediate)
    }
    
    func speak(_ utterance: String) {
        let utterance = AVSpeechUtterance(string: utterance)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        sythesizer.speak(utterance)
    }
    
}
