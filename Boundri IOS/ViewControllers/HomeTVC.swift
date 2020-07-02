//
//  HomeTVC.swift
//  Boundri IOS
//
//  Created by Tanner York on 6/22/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import Foundation
import UIKit

class HomeTVC: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at:indexPath, animated: true)
    }
}
 
