//
//  LoginVC.swift
//  Boundri IOS
//
//  Created by Tanner York on 7/28/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class LoginVC: UIViewController {
    
    //MARK: Properties
    @IBOutlet var loadingBackground: UIView!
    
    let captureSession = AVCaptureSession()
    let settings = AVCapturePhotoSettings()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    //Input
    var frontCamera: AVCaptureDevice?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkForPhotoAccess()
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

            view.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            view.backgroundColor = .black
        }
    }
    
    
}

//MARK: Background Delegate
//Extinsion for setting up the camera view and its options
extension LoginVC: AVCapturePhotoCaptureDelegate {
    func checkForPhotoAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            self.setupCaptureSession(loadingBackground)
            
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupCaptureSession(self.loadingBackground)
                }
            }
            
        case .denied: // The user has previously denied access.
            print("deined")
            let alert = UIAlertController(title: "Error", message: "App requires camera use. Pleace allow use of camera before playing.", preferredStyle: .alert)
            let allowAccess = UIAlertAction(title: "Open Settings", style: .default) { UIAlertAction in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { UIAlertAction in
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                //Comment if you want to minimise app
                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (timer) in
                    exit(0)
                }
            }
            alert.addAction(cancel)
            alert.addAction(allowAccess)
            self.present(alert, animated: true)
            return
            
        case .restricted: // The user can't grant access due to restrictions.
            print("resreicted")
            let alert = UIAlertController(title: "Error", message: "App requires camera use and your system seems to have restrictions.", preferredStyle: .alert)
            let allowAccess = UIAlertAction(title: "OK", style: .destructive) { UIAlertAction in
                UIControl().sendAction(#selector(URLSessionTask.suspend), to:  UIApplication.shared, for: nil)
                //Comment if you want to minimise app
                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (timer) in
                    exit(0)
                }
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { UIAlertAction in
                UIControl().sendAction(#selector(URLSessionTask.suspend), to:  UIApplication.shared, for: nil)
                //Comment if you want to minimise app
                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (timer) in
                    exit(0)
                }
            }
            alert.addAction(cancel)
            alert.addAction(allowAccess)
            self.present(alert, animated: true, completion: nil)
            return
            
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

