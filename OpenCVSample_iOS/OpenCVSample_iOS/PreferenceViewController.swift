//
//  TimedShotPopupViewController.swift
//  OpenCVSample_iOS
//
//  Created by Joemarie Aliling on 3/27/23.
//  Copyright © 2023 Hiroki Ishiura. All rights reserved.
//

import UIKit
import Foundation

class PreferenceViewController: UIViewController {
    var previousScreen = ""
    var playType = ""
    var timedShots = false
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override var shouldAutorotate: Bool {
        return false
    }
    @IBAction func goBack(_ sender: Any) {
        if previousScreen == "MainMenu"{
            let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "MainStory") as! MainController
            present(destinationVC, animated: true, completion: nil)
        } else if previousScreen == "ViewController"{
            let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "viewController") as! ViewController
            destinationVC.playType = self.playType
            destinationVC.timedShots = self.timedShots
            present(destinationVC, animated: true, completion: nil)
        }
    }
    
}
