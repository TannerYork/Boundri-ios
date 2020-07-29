//
//  TextHomeVC.swift
//  Boundri IOS
//
//  Created by Tanner York on 7/29/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class HomeVC: UIViewController {
    
    //MARK: Properties
    @IBOutlet var visionOutputBackground: UIView!
    @IBOutlet var tableView: UITableView!
    
    let captureSession = AVCaptureSession()
    let settings = AVCapturePhotoSettings()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    //Input
    var frontCamera: AVCaptureDevice?
    
    // Vision Options
    var selectedVisionOption: String  = ""
    let visionOptions: [[String:String]] = [
        [ "title": "Read Text",
          "details": "Reading any text in the cameras view outloud.",
          "icon": "doc.text"
        ],
        [ "title": "Detect Objects",
          "details": "Tells you where various opjects are and what their relationship to you are.",
          "icon": "keyboard"
        ]
    ]
    
    // Header Fadding
    var headerViewOriginalHeight: CGFloat = 0
    var titleLabel: UILabel = UILabel()
    var lastVerticalOffset: CGFloat = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set table view data source and delegate
        tableView.dataSource = self
        tableView.delegate = self
    
        // Setup custom styling
        self.navigationController!.navigationBar.prefersLargeTitles = true
        tableView.backgroundColor = .clear
        setupBackground()
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

            view.insertSubview(blurEffectView, at: 0)
        } else {
            view.backgroundColor = .black
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToVisionCameraVC" {
            guard let view = segue.destination as? VisionCameraVC else {return}
            view.visionOption = selectedVisionOption
        }
    }
}

//MARK: TableView Delegate
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visionOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VisionOptionCell") as! VisionOptionCell
        
        // Add dynamic type support
        cell.headlineLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        cell.headlineLabel!.adjustsFontForContentSizeCategory = true
        cell.detailsLabel!.font = UIFont.preferredFont(forTextStyle: .caption1)
        cell.detailsLabel!.adjustsFontForContentSizeCategory = true
        
        // Customize styles
        cell.backgroundColor = .clear
        cell.headlineLabel!.textColor = .white
        cell.detailsLabel!.textColor = .white
        
        // Set cell values
        cell.headlineLabel!.text = visionOptions[indexPath.row]["title"]
        cell.detailsLabel!.text = visionOptions[indexPath.row]["details"]
        cell.icon.image = UIImage(systemName: visionOptions[indexPath.row]["icon"]!)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedVisionOption = visionOptions[indexPath.row]["title"]!
        self.performSegue(withIdentifier: "segueToVisionCameraVC", sender: self)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if(velocity.y>0) {
         //Code will work without the animation block.I am using animation block incase if you want to set any delay to it.
            UIView.animate(withDuration: 2.5, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.navigationController?.navigationBar.prefersLargeTitles = false
         }, completion: nil)
        } else {
        UIView.animate(withDuration: 2.5, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.navigationController?.navigationBar.prefersLargeTitles = true
         }, completion: nil)
       }
    }
}

//MARK: Background Delegate
//Extinsion for setting up the camera view and its options
extension HomeVC: AVCapturePhotoCaptureDelegate {
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

