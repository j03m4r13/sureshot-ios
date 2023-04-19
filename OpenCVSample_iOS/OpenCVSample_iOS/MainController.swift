//
//  TimedShotPopupViewController.swift
//  OpenCVSample_iOS
//
//  Created by Joemarie Aliling on 3/27/23.
//  Copyright © 2023 Hiroki Ishiura. All rights reserved.
//

import UIKit
import Foundation

class MainController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override var shouldAutorotate: Bool {
        return false
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "10ShotsSegue" {
            if let destinationVC = segue.destination as? ViewController {

                print("10 shots segue fired")
                destinationVC.timedShots = true
                destinationVC.playType = "10Shots"
                segue.destination.performSelector(onMainThread: #selector(destinationVC.setPlayType(_:)), with: true, waitUntilDone: false)
            }
        }
    }
    
    @IBAction func performSegue(_ sender: Any) {
       performSegue(withIdentifier: "10ShotsSegue", sender: self)
//        print("10 SHOTS BUTTON")
//        let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
//        let destinationVC = storyboard.instantiateViewController(withIdentifier: "viewController") as! ViewController
//        destinationVC.timedShots = true
//        destinationVC.playType = "10Shots"
//        present(destinationVC, animated: true, completion: nil)
    }
}
