//
//  VisionOutputVC.swift
//  Boundri IOS
//
//  Created by Tanner York on 7/28/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class VisionOutputVC: UIViewController {
    
    //MARK: Properties
    @IBOutlet var visionOutputBackground: UIView!
    @IBOutlet var visionOutputTextView: UITextView!
    @IBOutlet var intentBox: UIView!
    @IBOutlet var activationPhraseLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    
    
    var visionOutput: String = ""
    var activationPhrase: String = ""
    
    let synthesizer = AVSpeechSynthesizer()
    let captureSession = AVCaptureSession()
    let settings = AVCapturePhotoSettings()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var frontCamera: AVCaptureDevice?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Label and TextView values
        self.visionOutputTextView.text = visionOutput
        self.activationPhraseLabel.text = self.activationPhrase
        
        // Setup custom UI
        setupBackground()
        visionOutputTextView.isScrollEnabled = false
        visionOutputTextView.sizeToFit()
        intentBox.sizeToFit()
        intentBox.layer.cornerRadius = 20
        doneButton.layer.cornerRadius = 30
        
        navigationItem.largeTitleDisplayMode = .never
        visionOutputTextView.font = UIFont.preferredFont(forTextStyle: .headline)
        visionOutputTextView!.adjustsFontForContentSizeCategory = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        let allVoices =  AVSpeechSynthesisVoice.speechVoices()

        var index = 0
        for theVoice in allVoices {
            print("Voice[\(index)] = \(theVoice)\n")
            index += 1
        }
        
        let utterance = AVSpeechUtterance(string: visionOutput)
        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Samantha-premium")
        synthesizer.speak(utterance)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    //MARK: Actions
    
    func setupBackground() {
        if !UIAccessibility.isReduceTransparencyEnabled {
            view.backgroundColor = .clear

            let blurEffect = UIBlurEffect(style: .prominent)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            let backgroundImage = UIImageView()
            backgroundImage.image = UIImage(named: "background-image")
            backgroundImage.frame = self.view.frame

            view.insertSubview(blurEffectView, at: 0)
            view.insertSubview(backgroundImage, at: 0)

        } else {
            view.backgroundColor = .black
        }
    }
    
    @IBAction func doneWasPressed() {
        self.performSegue(withIdentifier: "unwindToHomeVC", sender: self)
    }
}
