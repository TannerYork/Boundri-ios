//
//  HomeTVC.swift
//  Boundri IOS
//
//  Created by Tanner York on 6/22/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import Foundation
import UIKit
import Intents

class HomeTVC: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("I'm passing through HomeTVC")
//        AppIntent.allowSiri()
//        AppIntent.readText()
        INInteraction(intent: ReadTextIntent(), response: nil).donate(completion: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at:indexPath, animated: true)
    }
}
 
