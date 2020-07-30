//
//  CustomNavigationController.swift
//  Boundri IOS
//
//  Created by Tanner York on 7/28/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.view.backgroundColor = .clear
        self.navigationBar.isTranslucent = true
    }
}
