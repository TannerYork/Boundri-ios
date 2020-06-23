//
//  ImageViewVC.swift
//  Boundri IOS
//
//  Created by Tanner York on 6/22/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import UIKit

class ImageViewVC: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var choosePlayerButton: UIButton!
    
    var imageToPresent: UIImage?
    var selectedPlayer: String?
    var pickerView = UIPickerView()
    
    fileprivate var showNetworkActivityIndicator = false {
        didSet {
            UIApplication.shared.isNetworkActivityIndicatorVisible = showNetworkActivityIndicator
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image.image = imageToPresent
        choosePlayerButton.setTitleColor(UIColor(red:0.16, green:0.16, blue:0.17, alpha:1.0), for: .normal)
        
    }
    
    //MARK: Actions
    @IBAction func sendknockOut(_ sender: Any) {
        guard selectedPlayer != nil else {
            choosePlayerButton.setTitleColor(UIColor(red:1.00, green:0.29, blue:0.32, alpha:1.0), for: .normal)
            return
        }
//        FirestoreData.shared.addImage(imageToPresent!, of: selectedPlayer!, to: GameSession.shared.PlayerSession ?? GameSession.shared.AdminSession!, onComplete: { bool in
//            if bool == true {
//                self.dismiss(animated: true)
//            } else {
//                print("Error sending knockout")
//                Alerts.presentKnockOutErrorAlert(from: self)
//            }
//        })
    }
    
    @IBAction func cancelKnockOut(_ sender: Any) {
        //delete photo and return to camera view
        self.dismiss(animated: true)
    }
    
}

