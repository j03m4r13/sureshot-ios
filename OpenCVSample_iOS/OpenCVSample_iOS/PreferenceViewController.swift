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
    @IBOutlet var picker: UIPickerView!
    @IBOutlet var shootingPicker: UIPickerView!
    
    private var pickerData = ["Steel", "Brass Dropping", "Fun/Alien"]
    private var shootingPickerData = ["10 Shots", "Unlimited Shots"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.dataSource = self
        picker.delegate = self
        
        shootingPicker.dataSource = self
        shootingPicker.delegate = self
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

extension PreferenceViewController: UIPickerViewDataSource {
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            if pickerView == picker {
                return pickerData.count
            } else if pickerView == shootingPicker {
                return shootingPickerData.count
            }
            return 0
        }
    }
    
    // Modify the extension for UIPickerViewDelegate
    extension PreferenceViewController: UIPickerViewDelegate {
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            if pickerView == picker {
                return pickerData[row]
            } else if pickerView == shootingPicker {
                return shootingPickerData[row]
            }
            return nil
        }
    }

