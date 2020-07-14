//
//  CameraVC.swift
//  Boundri IOS
//
//  Created by Tanner York on 6/22/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController {
    
    //MARK: Properties
    @IBOutlet var cameraView: UIView!
    @IBOutlet var optionsView: UICollectionView!
    
    // Vision Options
    var visionOptions: [String] = ["text", "scene"]
    var selectedOption: String = "text"
    
    let captureSession = AVCaptureSession()
    let settings = AVCapturePhotoSettings()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    //Input
    var frontCamera: AVCaptureDevice?
    var backCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    
    //Output
    var output: AVCapturePhotoOutput?
    var imageCaptured: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        checkForPhotoAccess()
    }
    
    
    //MARK: Actions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToImageView" {
            guard let view = segue.destination as? ImageViewVC else {return}
            view.imageToPresent = imageCaptured
            view.visionOption = selectedOption
        }
    }
    
    
    @IBAction func cameraButtonDidTap(_ sender: Any) {
        let uniqueSettings = AVCapturePhotoSettings.init(from: settings)
        output?.capturePhoto(with: uniqueSettings, delegate: self)
    }
}


extension CameraVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.visionOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VisionCell", for: indexPath as IndexPath) as! VisionCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.visionLabel.text = self.visionOptions[indexPath.item]
        cell.layer.cornerRadius = 8
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedOption = visionOptions[indexPath.item]
        let uniqueSettings = AVCapturePhotoSettings.init(from: settings)
        output?.capturePhoto(with: uniqueSettings, delegate: self)
        
    }
}


//Extinsion for setting up the camera view and its options
extension CameraVC: AVCapturePhotoCaptureDelegate {
    func checkForPhotoAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            self.setupCaptureSession(cameraView)
            
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupCaptureSession(self.cameraView)
                }
            }
            
        case .denied: // The user has previously denied access.
            let alert = UIAlertController(title: "Error", message: "App requires camera use. Pleace allow use of camera before playing.", preferredStyle: .alert)
            let allowAccess = UIAlertAction(title: "Allow Access", style: .default) { UIAlertAction in
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.setupCaptureSession(self.cameraView)
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
        print(devices)
        for device in devices {
            print(device)
            if device.position == .back {
                backCamera = device
                print("Set backcamera to \(device)")
            } else if device.position == .front {
                frontCamera = device
                print("Set frontcamera to \(device)")
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
        
        imageCaptured = capturedImage
        self.performSegue(withIdentifier: "segueToImageView", sender: self)
    }
    
}
