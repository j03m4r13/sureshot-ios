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
    var soundFile = ""
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
        
        if self.playType != "" && self.playType != "TimedShots" {
            if let shootingType = UserDefaults.standard.string(forKey: "shootingType") {
                
                if shootingType == "10 Shots" {
                    shootingPicker.selectRow(0, inComponent: 0, animated: false)
                    self.playType = "10Shots"
                } else {
                    shootingPicker.selectRow(1, inComponent: 0, animated: false)
                    self.playType = "Unlimited Shots"

                }
                    
            } else {
                    print("No value was saved for key 'shootingType'")
                    // Save a value to UserDefaults
                    UserDefaults.standard.set("10 Shots", forKey: "shootingType")
                    shootingPicker.selectRow(0, inComponent: 0, animated: false)
                    self.playType = "10Shots"
            }
        }

        if let soundType = UserDefaults.standard.string(forKey: "soundType") {
            self.soundFile = soundType
            if soundFile == "Steel" {
                picker.selectRow(0, inComponent: 0, animated: false)
            } else if soundFile == "Brass Dropping"{
                picker.selectRow(1, inComponent: 0, animated: false)

            } else {
                picker.selectRow(2, inComponent: 0, animated: false)

            }
                
        } else {
            print("No value was saved for key 'soundType'")
            // Save a value to UserDefaults
            UserDefaults.standard.set("Steel", forKey: "soundType")
            picker.selectRow(0, inComponent: 0, animated: false)
            self.soundFile = "Steel"
        }

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
            if self.playType == "TimedShots" {
                destinationVC.setPlayType(true)
            }
            print("from PREFERENCE \(self.playType)")
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
    
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            
            if pickerView == shootingPicker {
                let selectedValue = self.shootingPickerData[row]
                UserDefaults.standard.set(selectedValue, forKey: "shootingType")
                if selectedValue == "10 Shots" {
                    shootingPicker.selectRow(0, inComponent: 0, animated: false)
                    self.playType = "10Shots"
                } else {
                    shootingPicker.selectRow(1, inComponent: 0, animated: false)
                    self.playType = "Unlimited Shots"

                }

                
                print("Selected value: \(selectedValue)")
            } else {
                let selectedValue = self.pickerData[row]
                UserDefaults.standard.set(selectedValue, forKey: "soundType")
                
                print("Selected value: \(selectedValue)")

            }
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

