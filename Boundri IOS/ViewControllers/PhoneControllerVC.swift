//
//  PhoneCameraControlerVC.swift
//  Boundri IOS
//
//  Created by Tanner York on 8/6/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import UIKit
import AVFoundation

class PhoneControlerVC: UIViewController {

    //MARK: Properties
    @IBOutlet fileprivate var capturePreviewView: UIView!
    @IBOutlet var currentShortcutLabel: UILabel!
    
    var visionShortcuts: [ShortcutsManager.Shortcut] = []
    var currentShortcut: ShortcutsManager.Shortcut!
    var currentShortcutNum: Int! {
        didSet {
            currentShortcut = visionShortcuts[currentShortcutNum]
        }
    }
    
    let sharedSpeackSythesizer = SpeechSythesizer.shared
    var activationPhrase: String = ""
    var visionOutput: String = ""
    
    // Capture Controller
    let cameraController = CameraController()
    var imageCaptured: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentShortcutNum != nil {
            currentShortcutNum = 0
        }
        
        func configureCameraController() {
            cameraController.prepare {(error) in
                if let error = error {
                    print(error)
                }
                try? self.cameraController.displayPreview(on: self.capturePreviewView)
            }
        }
        configureCameraController()
        reloadShortcuts()
        setupGestureReconizers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sharedSpeackSythesizer.stopSpeaking()
    }
    
    @IBAction func settingsBarButtonWasPressed() {
        self.navigationController?.pushViewController(ShortcutsManagerTVC(), animated: true)
    }
    
    @IBAction func unwindToPhoneControllerVC( _ seg: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToVisionOutputVC" {
            guard let view = segue.destination as? VisionOutputVC else {
                return
            }
            view.visionOutput = visionOutput
            view.activationPhrase = activationPhrase
        }
    }
    
}

// MARK: Gestures
extension PhoneControlerVC {
    func setupGestureReconizers() {
       let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
       swipeLeft.direction = .left
       let swipeRight = UISwipeGestureRecognizer(target: self, action:  #selector(handleSwipe(sender:)))
       swipeRight.direction = .right
        let tapScreen = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tapScreen.numberOfTapsRequired = 1
       
        view.addGestureRecognizer(tapScreen)
        view.addGestureRecognizer(swipeLeft)
        view.addGestureRecognizer(swipeRight)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended && currentShortcut.kind.gestureType == "tap"{
            
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()

            cameraController.captureImage {(image, error) in
                guard let image = image else {
                    print(error ?? "Image capture error")
                    return
                }
                ImageProcessor.shared.proccess(image: image, with: self.currentShortcut.kind) { (results) in
                    self.visionOutput = results["output"]!
                    self.activationPhrase = results["phrase"]!
                    self.performSegue(withIdentifier: "segueToVisionOutputVC", sender: self)
                }
                
            }
        }
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            switch sender.direction {
            case .left:
                changeCurrentShortcut(toThe: "right")
            case .right:
                changeCurrentShortcut(toThe: "left")
            default:
                return
            }
        }
    }
}


// MARK: Shortcuts
extension PhoneControlerVC {
    func reloadShortcuts() {
        ShortcutsManager.shared.loadShortcuts(kinds: ShortcutsManager.Kind.allCases) { [weak self] shortcuts in
            self?.visionShortcuts = shortcuts.filter { $0.voiceShortcut != nil }
            DispatchQueue.main.async {
                self!.setupShortcutChange()
            }
        }
    }
    
    func setupShortcutChange() {
        guard visionShortcuts.count != 0, currentShortcutNum == nil else {
            return
        }
        guard visionShortcuts.count == 1 else {
            currentShortcutNum = 0
            return
        }
        currentShortcutNum = 0
        self.navigationItem.title = currentShortcut.kind.suggestedInvocationPhrase
        currentShortcutLabel.text = currentShortcut.kind.suggestedInvocationPhrase
    }
    
    func changeCurrentShortcut(toThe direction: String) {
        if direction == "right" {
            guard currentShortcutNum != visionShortcuts.count-1 else {
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
                return
            }
            
            currentShortcutNum += 1
            
            self.navigationItem.title = currentShortcut.kind.suggestedInvocationPhrase
            currentShortcutLabel.text = currentShortcut.kind.suggestedInvocationPhrase
            
            sharedSpeackSythesizer.speak(currentShortcut.invocationPhrase!)
            
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        } else if direction == "left" {
            guard currentShortcutNum != 0 else {
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
                return
            }
            sharedSpeackSythesizer.stopSpeaking()
            currentShortcutNum -= 1
            
            self.navigationItem.title = currentShortcut.kind.suggestedInvocationPhrase
            currentShortcutLabel.text = currentShortcut.kind.suggestedInvocationPhrase
            
            sharedSpeackSythesizer.speak(currentShortcut.invocationPhrase!)
            
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
}
