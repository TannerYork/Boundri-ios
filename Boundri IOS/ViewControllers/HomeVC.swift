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
import Intents

class HomeVC: UIViewController {
    
    //MARK: Properties
    @IBOutlet var visionOutputBackground: UIView!
    @IBOutlet var tableView: UITableView!
    
    let captureSession = AVCaptureSession()
    let settings = AVCapturePhotoSettings()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var frontCamera: AVCaptureDevice?
    
    // Vision Options
    var visionOptions: [ShortcutsManager.Shortcut] = []
    var selectedVisionOption: ShortcutsManager.Kind!
    
    // Header Fadding
    var headerViewOriginalHeight: CGFloat = 0
    var titleLabel: UILabel = UILabel()
    var lastVerticalOffset: CGFloat = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set table view data source and delegate
        tableView.dataSource = self
        tableView.delegate = self
    
        reloadShortcuts()
        
        // Setup custom styling
        self.navigationController!.navigationBar.prefersLargeTitles = true
        tableView.backgroundColor = .clear
        setupBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadShortcuts()
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

            let backgroundImage = UIImageView()
            backgroundImage.image = UIImage(named: "background-image")
            backgroundImage.frame = self.view.frame
            
            view.insertSubview(blurEffectView, at: 0)
            view.insertSubview(backgroundImage, at: 0)
        } else {
            view.backgroundColor = .black
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToVisionCameraVC" {
            guard let view = segue.destination as? VisionCameraVC else {return}
            view.shortcutKind = selectedVisionOption
            view.captureButtonWasPressed = false
        }
    }
    
    @IBAction func unwindToHomeVC( _ seg: UIStoryboardSegue) {
    }
    
    
    @IBAction func settingsBarButtonWasPressed() {
        self.navigationController?.pushViewController(ShortcutsManagerTVC(), animated: true)
    }
    
    func reloadShortcuts() {
        ShortcutsManager.shared.loadShortcuts(kinds: ShortcutsManager.Kind.allCases) { [weak self] shortcuts in
            self?.visionOptions = shortcuts.filter { $0.voiceShortcut != nil }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
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
        let shortcut = visionOptions[indexPath.row]
        
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
        cell.headlineLabel!.text = shortcut.kind.suggestedInvocationPhrase
        let phrase = shortcut.voiceShortcut?.invocationPhrase ?? ""
        cell.detailsLabel!.text = phrase.isEmpty ? nil : "Say \"" + phrase + "\""
        cell.icon.image = UIImage(systemName: shortcut.kind.intentIcon)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedVisionOption = visionOptions[indexPath.row].kind
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

