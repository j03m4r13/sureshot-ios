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
    @IBOutlet weak var numRounds: UISlider!
    @IBOutlet weak var shotInterval: UISlider!
    @IBOutlet weak var numRoundsLabel: UILabel!
    @IBOutlet weak var shotIntervalLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numRounds.isContinuous = true
        shotInterval.isContinuous = true

        
      
        if let shotsPerRound = UserDefaults.standard.string(forKey: "shotsPerRound") {
            let shotsRound = Int(shotsPerRound)
            print("The saved value is: \(shotsPerRound)")
            numRounds.value = Float(shotsPerRound) ?? 3.0
            
        } else {
            print("No value was saved for key 'shotsPerRound'")
            // Save a value to UserDefaults
            let shotsPerRound = 3
            UserDefaults.standard.set(shotsPerRound, forKey: "shotsPerRound")
            numRounds.value = Float(shotsPerRound)

        }
        if let shotsInterval = UserDefaults.standard.string(forKey: "shotsInterval") {
            let shotsIntervalInt = Int(shotsInterval)
            print("The saved value is: \(shotsInterval)")
            shotInterval.value = Float(shotsInterval) ?? 5.0
        } else {
            print("No value was saved for key 'shotsPerRound'")
            // Save a value to UserDefaults
            let shotsInterval = 5
            UserDefaults.standard.set(shotsInterval, forKey: "shotsInterval")
            shotInterval.value = Float(shotsInterval)

        }
        numRoundsLabel.text = "\(Int(numRounds.value))"
        shotIntervalLabel.text = "\(Int(shotInterval.value))"
    }
    override var shouldAutorotate: Bool {
        return false
    }
    
    @IBAction func numberOfRoundsSlide(_ sender: Any) {
        // Update the label's text to match the slider's value
        let roundedValue = round(numRounds.value)
        numRounds.value = roundedValue
        numRoundsLabel.text = "\(Int(numRounds.value))"
    }

    @IBAction func shotIntervalSlide(_ sender: Any) {
        // Update the label's text to match the slider's value
        let roundedValue = round(shotInterval.value)
        shotInterval.value = roundedValue
        shotIntervalLabel.text = "\(Int(shotInterval.value))"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "timedSeqSegue" {
            print("TIMED SEGUE FIRED")
            if let destinationVC = segue.destination as? ViewController {
                let shotsPerRound = Int(numRounds.value)
                
                UserDefaults.standard.set(shotsPerRound, forKey: "shotsPerRound")
                numRounds.value = Float(shotsPerRound)
                let shotsInterval = Int(shotInterval.value)
                UserDefaults.standard.set(shotsInterval, forKey: "shotsInterval")
                shotInterval.value = Float(shotsInterval)

                destinationVC.timedShots = true
                destinationVC.playType = "TimedShots"
                segue.destination.performSelector(onMainThread: #selector(destinationVC.setPlayType(_:)), with: true, waitUntilDone: false)
            }
        }
    }
    @IBAction func resetSettings(_ sender: Any) {
        shotInterval.value = 5
        numRounds.value = 5
    }
    
    @IBAction func performSegue(_ sender: Any) {
        performSegue(withIdentifier: "timedSeqSegue", sender: self)
    }
}
