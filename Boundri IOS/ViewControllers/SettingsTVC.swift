//
//  SettingsTVC.swift
//  Boundri IOS
//
//  Created by Tanner York on 6/28/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import Foundation
import UIKit

class SiriSettingsTVC: UITableViewController {
    
    //MARK: Properties
    @IBOutlet weak var textToVoiceSwitch: UISwitch!
    @IBOutlet weak var describeSceneSwitch: UISwitch!
    
    @IBOutlet weak var americanEnglishSelection: UITableViewCell!
    @IBOutlet weak var britishEnglishSelection: UITableViewCell!
    
    
    var laguageSelectors = [UITableViewCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        laguageSelectors = [
            americanEnglishSelection
        ]
    }
    
    //MARK: Actions
    
    @IBAction func textToVoiceDidTap() {
        if textToVoiceSwitch.isOn {
            // Activate text to voice in SiriKit
            print("Text to Voice is on")
        } else {
            // Deactivate text to voice in SiriKit
            print("Text to Voice is off")
        }
    }
    
    
    @IBAction func describeSceneSwitchDidTap() {
        if describeSceneSwitch.isOn {
            // Activate describe scene in SiriKit
            print("Desc Scene is on")
        } else {
            // Deactivate describe scene in SiriKit
            print("Desc Scene is off")
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            for index in 0...laguageSelectors.count-1 {
                let path = IndexPath(row: index, section: 1)
                let cell = self.tableView.cellForRow(at: path )
                if index == indexPath.row {
                    cell?.accessoryType = .checkmark
                } else {
                    cell?.accessoryType = .none
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

}
