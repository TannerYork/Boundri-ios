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
    var visionOutput: String = ""
    
    let captureSession = AVCaptureSession()
    let settings = AVCapturePhotoSettings()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    //Input
    var frontCamera: AVCaptureDevice?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        navigationItem.largeTitleDisplayMode = .never
        visionOutputTextView.font = UIFont.preferredFont(forTextStyle: .headline)
        visionOutputTextView!.adjustsFontForContentSizeCategory = true
        setupBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.visionOutputTextView.text = visionOutput
        checkForPhotoAccess()
        
        let utterance = AVSpeechUtterance(string: visionOutput)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")

        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    //MARK: Actions
    
    func setupBackground() {
        if !UIAccessibility.isReduceTransparencyEnabled {
            view.backgroundColor = .clear

            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            view.insertSubview(blurEffectView, at: 0)
        } else {
            view.backgroundColor = .black
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToVisionCameraVC" {
            guard let view = segue.destination as? VisionCameraVC else {return}
            view.captureButtonWasPressed = false
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        // Perform your custom actions
        self.performSegue(withIdentifier: "unwindToVisionCameraVC", sender: self)
    }
}

//MARK: Background Delegate
//Extinsion for setting up the camera view and its options
extension VisionOutputVC: AVCapturePhotoCaptureDelegate {
    func checkForPhotoAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            self.setupCaptureSession(visionOutputBackground)
            
        @unknown default:
            let alert = UIAlertController(title: "Error", message: "An unknown error hass occured", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(confirmAction)
            return
        }
    }
    
    func setupCaptureSession(_ view: UIView) {
        captureSession.sessionPreset = .photo
        
        //Errors
        enum CameraSetupErros: Error {
            case invaledCamera
        }
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        let devices = deviceDiscoverySession.devices
        print(devices)
        for device in devices {
            print(device)
            if device.position == .front {
                frontCamera = device
                print("Set frontcamera to \(device)")
            }
        }
        
        //Configure settings
        //        settings.isAutoStillImageStabilizationEnabled = true
        settings.isHighResolutionPhotoEnabled = false
        settings.flashMode = .auto
        
        do {
            guard let captureDeviceInput = try? AVCaptureDeviceInput(device: frontCamera!) else {
                throw CameraSetupErros.invaledCamera
            }
            if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
                for input in inputs {
                    captureSession.removeInput(input)
                }
            }
            captureSession.addInput(captureDeviceInput)
            
            //Setup camera preview layer
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.videoGravity = .resizeAspectFill
            previewLayer?.connection?.videoOrientation = .portrait
            previewLayer?.frame = view.frame
            view.layer.insertSublayer(previewLayer!, at: 0)
            captureSession.startRunning()
            
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}


