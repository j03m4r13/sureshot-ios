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
    var playType = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        if let shootingType = UserDefaults.standard.string(forKey: "shootingType") {
            // DO NOTHING
                
        } else {
            print("No value was saved for key 'shootingType'")
            // Save a value to UserDefaults
            UserDefaults.standard.set("10 Shots", forKey: "shootingType")
        }

    }
    override var shouldAutorotate: Bool {
        return false
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "10ShotsSegue" {
            if let destinationVC = segue.destination as? ViewController {

                print("10 shots segue fired")
                destinationVC.timedShots = true
                if let shootingType = UserDefaults.standard.string(forKey: "shootingType") {
                    
                    if shootingType == "10 Shots" {
                        self.playType = "10Shots"
                    } else if shootingType == "Unlimited Shots" {
                        self.playType = "Unlimited Shots"

                    } else {
                        self.playType = "TimedShots"

                    }
                        
                }
                destinationVC.playType = self.playType

                segue.destination.performSelector(onMainThread: #selector(destinationVC.setPlayType(_:)), with: true, waitUntilDone: false)
            }
        } else if segue.identifier == "fromMainMenuSegue" {
            if let destinationVC = segue.destination as? PreferenceViewController {
                if let shootingType = UserDefaults.standard.string(forKey: "shootingType") {
                    
                    if shootingType == "10 Shots" {
                        self.playType = "10Shots"
                    } else if shootingType == "Unlimited Shots" {
                        self.playType = "Unlimited Shots"

                    } else {
                        self.playType = "TimedShots"

                    }
                        
                }
                destinationVC.previousScreen = "MainMenu"
                destinationVC.playType = self.playType
   

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
    
    @IBAction func showPreference(_ sender: Any) {
       performSegue(withIdentifier: "fromMainMenuSegue", sender: self)
//        print("10 SHOTS BUTTON")
//        let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
//        let destinationVC = storyboard.instantiateViewController(withIdentifier: "viewController") as! ViewController
//        destinationVC.timedShots = true
//        destinationVC.playType = "10Shots"
//        present(destinationVC, animated: true, completion: nil)
    }
}
