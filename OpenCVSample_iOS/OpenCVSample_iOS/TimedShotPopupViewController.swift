//
//  TimedShotPopupViewController.swift
//  OpenCVSample_iOS
//
//  Created by Joemarie Aliling on 3/27/23.
//  Copyright © 2023 Hiroki Ishiura. All rights reserved.
//

import UIKit
import Foundation

class TimedShotPopupViewController: UIViewController {
    
    @IBOutlet weak var numberOfRoundTextField: UITextField!
    @IBOutlet weak var shotIntervalTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let shotsPerRound = UserDefaults.standard.string(forKey: "shotsPerRound") {
            if let shotsRound = Int(shotsPerRound) {
                print("The saved value is: \(shotsRound)")
                numberOfRoundTextField.text = String(shotsRound)
            }
        } else {
            print("No value was saved for key 'shotsPerRound'")
            // Save a value to UserDefaults
            let shotsPerRound = 3
            UserDefaults.standard.set(String(shotsPerRound), forKey: "shotsPerRound")
            numberOfRoundTextField.text = String(shotsPerRound)
        }
        
        if let shotsInterval = UserDefaults.standard.string(forKey: "shotsInterval") {
            if let shotsIntervalInt = Int(shotsInterval) {
                print("The saved value is: \(shotsIntervalInt)")
                shotIntervalTextField.text = String(shotsIntervalInt)
            }
        } else {
            print("No value was saved for key 'shotsInterval'")
            // Save a value to UserDefaults
            let shotsInterval = 5
            UserDefaults.standard.set(String(shotsInterval), forKey: "shotsInterval")
            shotIntervalTextField.text = String(shotsInterval)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true) // This will hide the keyboard for any active text field or text view
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    @IBAction func numberOfRoundsSlide(_ sender: Any) {
        
    }
    
    @IBAction func shotIntervalSlide(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "timedSeqSegue" {
            print("TIMED SEGUE FIRED")
            if let destinationVC = segue.destination as? ViewController {
                if let shotsPerRound = Int(numberOfRoundTextField.text ?? "") {
                    UserDefaults.standard.set(String(shotsPerRound), forKey: "shotsPerRound")
                    numberOfRoundTextField.text = String(shotsPerRound)
                }
                
                if let shotsInterval = Int(shotIntervalTextField.text ?? "") {
                    UserDefaults.standard.set(String(shotsInterval), forKey: "shotsInterval")
                    shotIntervalTextField.text = String(shotsInterval)
                }

                destinationVC.timedShots = true
                destinationVC.playType = "TimedShots"
                segue.destination.performSelector(onMainThread: #selector(destinationVC.setPlayType(_:)), with: true, waitUntilDone: false)
            }
        }
    }
    
    @IBAction func resetSettings(_ sender: Any) {
        shotIntervalTextField.text = "5"
        numberOfRoundTextField.text = "5"
    }
    
    @IBAction func performSegue(_ sender: Any) {
        performSegue(withIdentifier: "timedSeqSegue", sender: self)
    }
}
