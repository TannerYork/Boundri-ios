////
////  Camera.swift
////  Boundri IOS
////
////  Created by Tanner York on 7/30/20.
////  Copyright © 2020 Boundri. All rights reserved.
////
//
//import Foundation
//import AVFoundation
//import UIKit
//
//class Camera: AVCapturePhotoCaptureDelegate {
//
//    let captureSession = AVCaptureSession()
//    let settings = AVCapturePhotoSettings()
//    var previewLayer: AVCaptureVideoPreviewLayer?
//
//    //Input
//    var frontCamera: AVCaptureDevice?
//    var backCamera: AVCaptureDevice?
//    var currentCamera: AVCaptureDevice?
//    var captureButtonWasPressed: Bool = false
//
//    //Output
//    var output: AVCapturePhotoOutput?
//
//    func checkForPhotoAccess() {
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .authorized: // The user has previously granted access to the camera.
//            self.setupCaptureSession()
//        case .notDetermined: // The user has not yet been asked for camera access.
//            AVCaptureDevice.requestAccess(for: .video) { granted in
//                if granted {
//                    self.setupCaptureSession(self.visionCameraView)
//                }
//            }
//
//        case .denied: // The user has previously denied access.
//
//            return
//
//        case .restricted: // The user can't grant access due to restrictions.
//            return
//
//        @unknown default:
//            return
//        }
//    }
//
//    func setupCaptureSession(_ view: UIView) {
//        captureSession.sessionPreset = .photo
//
//        //Errors
//        enum CameraSetupErros: Error {
//            case invaledCamera
//        }
//
//        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
//        let devices = deviceDiscoverySession.devices
//        print(devices)
//        for device in devices {
//            print(device)
//            if device.position == .back {
//                backCamera = device
//                print("Set backcamera to \(device)")
//            } else if device.position == .front {
//                frontCamera = device
//                print("Set frontcamera to \(device)")
//            }
//        }
//
//        //Set default device
//        currentCamera = backCamera
//
//        //Configure the session with the output or capturing the image
//        output = AVCapturePhotoOutput()
//        output!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
//
//        //Configure settings
//        //        settings.isAutoStillImageStabilizationEnabled = true
//        settings.isHighResolutionPhotoEnabled = false
//        settings.flashMode = .auto
//
//        do {
//            guard let captureDeviceInput = try? AVCaptureDeviceInput(device: currentCamera!) else {
//                throw CameraSetupErros.invaledCamera
//            }
//            if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
//                for input in inputs {
//                    captureSession.removeInput(input)
//                }
//            }
//            captureSession.addInput(captureDeviceInput)
//            if captureSession.canAddOutput(output!) {
//                print("Added \(String(describing: output))")
//                captureSession.addOutput(output!)
//            } else {
//                print("\n\n Can't add output \n\n" )
//            }
//
//            //Setup camera preview layer
//            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//            previewLayer?.videoGravity = .resizeAspectFill
//            previewLayer?.connection?.videoOrientation = .portrait
//            previewLayer?.frame = view.frame
//            view.layer.insertSublayer(previewLayer!, at: 0)
//            captureSession.startRunning()
//
//        } catch {
//            print("Error: \(error.localizedDescription)")
//        }
//    }
//
//    //Gets the output of the captures photo button
//    func photoOutput(_ output: AVCapturePhotoOutput,
//                     didFinishProcessingPhoto photo: AVCapturePhoto,error: Error?) {
//        let imageData = photo.fileDataRepresentation()
//        guard let capturedImage = UIImage.init(data: imageData!, scale: 1.0) else {
//            print("Error setting image data to UIImage")
//            return
//        }
//
////        processImage(capturedImage, with: visionOption)
//    }
//
//
//}
