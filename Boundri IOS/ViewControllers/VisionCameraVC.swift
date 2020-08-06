//
//  VisionCameraVC.swift
//  Boundri IOS
//
//  Created by Tanner York on 7/28/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import UIKit
import AVFoundation
import MLKit

class VisionCameraVC: UIViewController {
    
    //MARK: Properties
    @IBOutlet var visionCameraView: UIView!
    var visionOption: VisionOptionType!
    var activationPhrase: String = ""
    var visionOutput: String! {
        didSet {
            self.performSegue(withIdentifier: "segueToVisionOutputVC", sender: self)
        }
    }
    
    let captureSession = AVCaptureSession()
    let settings = AVCapturePhotoSettings()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    //Input
    var frontCamera: AVCaptureDevice?
    var backCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var captureButtonWasPressed: Bool = false
    
    //Output
    var output: AVCapturePhotoOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        checkForPhotoAccess()
    }
    
    
    //MARK: Actions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToVisionOutputVC" {
            guard let view = segue.destination as? VisionOutputVC else {return}
            view.visionOutput = visionOutput
            view.activationPhrase = activationPhrase
        }
    }
    
    @IBAction func cameraButtonDidTap(_ sender: Any) {
        if captureButtonWasPressed {return}
        captureButtonWasPressed = true
        let uniqueSettings = AVCapturePhotoSettings.init(from: settings)
        output?.capturePhoto(with: uniqueSettings, delegate: self)
    }
}


//MARK: Capture Delegate
//Extinsion for setting up the camera view and its options
extension VisionCameraVC: AVCapturePhotoCaptureDelegate {
    func checkForPhotoAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            self.setupCaptureSession(visionCameraView)
            
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupCaptureSession(self.visionCameraView)
                }
            }
            
        case .denied: // The user has previously denied access.
            let alert = UIAlertController(title: "Error", message: "App requires camera use. Pleace allow use of camera before playing.", preferredStyle: .alert)
            let allowAccess = UIAlertAction(title: "Allow Access", style: .default) { UIAlertAction in
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.setupCaptureSession(self.visionCameraView)
                    }
                }
            }
            alert.addAction(allowAccess)
            return
            
        case .restricted: // The user can't grant access due to restrictions.
            let alert = UIAlertController(title: "Error", message: "App requires camera use and your system seems to have restrictions.", preferredStyle: .alert)
            let allowAccess = UIAlertAction(title: "OK", style: .destructive) { UIAlertAction in
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
            }
            alert.addAction(allowAccess)
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
        for device in devices {
            if device.position == .back {
                backCamera = device
            } else if device.position == .front {
                frontCamera = device
            }
        }
        
        //Set default device
        currentCamera = backCamera
        
        //Configure the session with the output or capturing the image
        output = AVCapturePhotoOutput()
        output!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
        
        //Configure settings
        //        settings.isAutoStillImageStabilizationEnabled = true
        settings.isHighResolutionPhotoEnabled = false
        settings.flashMode = .auto
        
        do {
            guard let captureDeviceInput = try? AVCaptureDeviceInput(device: currentCamera!) else {
                throw CameraSetupErros.invaledCamera
            }
            if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
                for input in inputs {
                    captureSession.removeInput(input)
                }
            }
            captureSession.addInput(captureDeviceInput)
            if captureSession.canAddOutput(output!) {
                print("Added \(String(describing: output))")
                captureSession.addOutput(output!)
            } else {
                print("\n\n Can't add output \n\n" )
            }
            
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
    
    //Gets the output of the captures photo button
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,error: Error?) {
        let imageData = photo.fileDataRepresentation()
        guard let capturedImage = UIImage.init(data: imageData!, scale: 1.0) else {
            print("Error setting image data to UIImage")
            return
        }
        
        VisionOptionsManager.shared.proccess(image: capturedImage, with: self.visionOption) { (results) in
            self.activationPhrase = results["phrase"]!
            self.visionOutput = results["output"]!
        }
    }
    
}

