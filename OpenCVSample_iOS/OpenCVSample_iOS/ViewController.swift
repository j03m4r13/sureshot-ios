//
//  ViewController.swift
//  OpenCVSample_iOS
//
//  Created by Hiroki Ishiura on 2020/01/04.
//  Copyright © 2020 Hiroki Ishiura. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import QuartzCore

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
	
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var readyText: UILabel!
    
    var player: AVAudioPlayer?
	var session: AVCaptureSession!
	var device: AVCaptureDevice!
	var output: AVCaptureVideoDataOutput!
    var s1: Float!
    var firstFrameImg: UIImage!
    var resultImg: UIImage!
    var firstFrame: Bool!
    var hasStarted: Bool!
    var showingResult: Bool!
    var isPlaying: Bool!
    var zoomLevel: CGFloat!
    var playType = ""
    var shotsCount: Int32!
    var timer: Timer?
    
    var XYArray: [CGPoint] = []
    var timeRecords: [Double] = []
    var roundsCount: Int32!
    var totalRounds: Int32!
    var timePerRound: Double!
    var elapsedTime: Double!
    var timeNow: Double!
    var timedCountStarted: Bool!
    var timedShots: Bool?
    var preTimerHasRan: Bool! = false
    var timerHasRan: Bool! = false
    var timerCount: Int!
    var timerPre: Timer?
    var timerPreHasStarted: Bool! = false
    var mainTimerRan: Bool! = false
    var numRounds: Int!
    var shotInterval: Int!
    var timedShotCount: Int32!
    var timedShotTimer: Timer?
    var timedShotPreTimer: Timer?
    var timedShotPauseTimer: Timer?
    var soundType = ""
    var shootingType = ""
    var shooterReadySoundPlaying: Bool! = false
    var isShowingResetPane: Bool! = false;
    var imageReset: UIImage!
    var unliTempImg: UIImage!
    var unliShotStarted: Bool! = false
    @objc func setPlayType(_ value: Bool) {

        self.timedShots = value

        print("Play Type value \(value)")
        self.timedShotCount = 0
        self.timerCount = 3
        if let shotsPerRound = UserDefaults.standard.string(forKey: "shotsPerRound") {
            let shotsRound = Int(shotsPerRound)
            print("The saved value is: \(shotsPerRound)")
            numRounds = Int(shotsPerRound)


        }
        if let shotsInterval = UserDefaults.standard.string(forKey: "shotsInterval") {
            let shotsIntervalInt = Int(shotsInterval)
            print("The saved value is: \(shotsIntervalInt)")
            shotInterval = Int(shotsInterval)


        }
    }
	override func viewDidLoad() {
		super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        s1 = 1.0
        zoomLevel = 1
        shotsCount = 0
        firstFrame = true
        hasStarted = false
        showingResult = false
        isPlaying = false
        timerHasRan = false
        preTimerHasRan = false
        timedCountStarted = false
        unliShotStarted = false
        timerCount = 3
        //playType = ""
        timerPre = nil
        self.countDownLabel.text = ""
		// Prepare a video capturing session.
		self.session = AVCaptureSession()
        self.session.sessionPreset = AVCaptureSession.Preset.vga640x480 // not work in iOS simulator
		guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else {
			print("no device")
			return
		}
        let newXY = CGPoint(x: 0, y: 0)
        
        
        XYArray.append(newXY)
        XYArray.append(newXY)
        XYArray.append(newXY)
        XYArray.append(newXY)
        XYArray.append(newXY)
        XYArray.append(newXY)
        XYArray.append(newXY)
        XYArray.append(newXY)
        XYArray.append(newXY)
        XYArray.append(newXY)
        
        if let shootingType = UserDefaults.standard.string(forKey: "shootingType") {
            self.shootingType = shootingType
                
        } else {
            self.shootingType = "10 Shots"
        }

        if let soundType = UserDefaults.standard.string(forKey: "soundType") {
            self.soundType = soundType
                
        } else {
            print("No value was saved for key 'soundType'")
            self.soundType = "Steel"
        }
        
		self.device = device
		do {
			let input = try AVCaptureDeviceInput(device: self.device)
			self.session.addInput(input)
		} catch {
			print("no device input")
			return
		}
		self.output = AVCaptureVideoDataOutput()
		self.output.videoSettings = [ kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA) ]
		let queue: DispatchQueue = DispatchQueue(label: "videocapturequeue", attributes: [])
		self.output.setSampleBufferDelegate(self, queue: queue)
		self.output.alwaysDiscardsLateVideoFrames = false
		if self.session.canAddOutput(self.output) {
			self.session.addOutput(self.output)
		} else {
			print("could not add a session output")
			return
		}
		do {
			try self.device.lockForConfiguration()
			self.device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 30) // 20 fps'
            self.device.videoZoomFactor = self.zoomLevel
            self.device.exposureMode = .locked
			self.device.unlockForConfiguration()
		} catch {
			print("could not configure a device")
			return
		}

		self.session.startRunning()
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
        
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = sender.value
        s1 = currentValue
        valueLabel.text = "\(currentValue)"
    }
    
    @IBAction func ZoomInBtn(_ sender: UIButton) {
        do {
            self.zoomLevel += 0.3
            if(self.zoomLevel >= 7){ self.zoomLevel = 7.0 }
            print("\(self.zoomLevel)")
            try self.device.lockForConfiguration()
            self.device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale:60) // 20 fps'
            self.device.videoZoomFactor = self.zoomLevel
            self.device.exposureMode = .locked
            self.device.unlockForConfiguration()
        } catch {
            print("could not configure a device")
            return
        }

    }
    
    @IBAction func ZoomOutBtn(_ sender: UIButton) {
        do {
            self.zoomLevel -= 0.3
            if(self.zoomLevel <= 1.0){ self.zoomLevel = 1.0 }
            print("\(self.zoomLevel)")
            try self.device.lockForConfiguration()
            self.device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale:60) // 20 fps'
            self.device.videoZoomFactor = self.zoomLevel
            self.device.exposureMode = .locked
            self.device.unlockForConfiguration()
        } catch {
            print("could not configure a device")
            return
        }
    }
    
    
    @IBAction func settings(_ sender: UIButton) {
    
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "TimedShotPopupViewController")

        show(secondVC, sender: self)
    }
    
    
    
    @IBAction func startShoot(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
//        let destinationVC = storyboard.instantiateViewController(withIdentifier: "resultsView") as! ResultsViewController
//        destinationVC.timeRecordsData = timeRecords
//        present(destinationVC, animated: true, completion: nil)
//
//
//        return;
//
//        self.playType = "10Shots"
//        self.playType = "TimedShots"
        print("PLAYTYPE: \(self.playType ?? "")")
        var countDown = 3
        self.shotsCount = 0
        self.timerCount = 3
        self.timedShotCount = 0
        self.isShowingResetPane = false
        self.unliShotStarted = false
        
        if(startBtn.currentAttributedTitle?.string == "START"){
            
            let copperFont = UIFont(name: "Copperplate", size: 24)!
            let boldCopperFontDescriptor = copperFont.fontDescriptor.withSymbolicTraits(.traitBold)!
            let boldCopperFont = UIFont(descriptor: boldCopperFontDescriptor, size: 24)

            let attributedString = NSAttributedString(string: "STOP", attributes: [.font: boldCopperFont])
            self.startBtn.setAttributedTitle(attributedString, for: .normal)
            self.showingResult = false
            if(self.playType == "10Shots"){
                if(self.timer != nil){
                    self.timer?.invalidate()
                }
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {timer in
                    // Handle timer tick here
                    self.countDownLabel.text = "\(countDown)"
                    if(countDown == 0){
                        self.timer?.invalidate()
                        self.hasStarted = true
                        self.countDownLabel.text = ""
                        self.showingResult = false
                        self.firstFrame = true
                        
                        
                        
                    }
                    countDown -= 1
                }
                
                // Start the timer
                timer?.fire()
            } else if(self.playType == "Unlimited Shots") {
                if(self.timer != nil){
                    self.timer?.invalidate()
                }
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {timer in
                    // Handle timer tick here
                    self.countDownLabel.text = "\(countDown)"
                    if(countDown == 0){
                        self.timer?.invalidate()
                        self.hasStarted = true
                        self.countDownLabel.text = ""
                        self.showingResult = false
                        self.firstFrame = true
                        


                    }
                    countDown -= 1
                }

                // Start the timer
                timer?.fire()

            } else if (self.playType == "TimedShots"){
                    
                self.timedShotPreTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timedShotPreTimer in
                            // Handle timer tick here
                        if(self.timerCount == 0){
                            self.readyText.isHidden = true
                            print("TIMER FINISHED")
                            //self.mainTimerRan
                            self.preTimerHasRan = true
                            self.countDownLabel.text = ""
                            self.hasStarted = true
                            self.showingResult = false
                            self.firstFrame = true
                            //self.timedShotCount = self.timedShotCount + 1
                            
                            
                            if(self.preTimerHasRan){
                                self.preTimerHasRan = false
                                self.shooterReadySoundPlaying = false
                                self.timerCount = -1
                                let seed = Int.random(in: 500..<3000)
                                let randTime = Double(Double(seed) / 1000.0)
                                print(randTime)
                                self.timedShotPauseTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timedShotPauseTimer in
                                    // Handle timer tick here
//                                    self.playBeep()
//                                    self.timeNow = CACurrentMediaTime() * 1000.0
//                                    self.timerHasRan = true
                                    //timerPause.invalidate()

                                }
                                self.timedShotPauseTimer?.fire()
                                DispatchQueue.main.asyncAfter(deadline: .now() + randTime) {
                                    self.timedShotPauseTimer?.invalidate()
                                    self.playBeep()
                                    self.timeNow = CACurrentMediaTime() * 1000.0
                                    self.timerHasRan = true
                                }

                            }
                        }else if (self.timerCount > 0){
                            self.readyText.isHidden = true
                            //self.countDownLabel.text = "\(self.timerCount!)"
                            self.countDownLabel.text = ""
                            self.timerCount = self.timerCount - 1
                            print("\(self.timerCount!)")
                            if self.shooterReadySoundPlaying == false {
                                // play only once
                                self.shooterReadySoundPlaying = true
                                self.playShooterReady()
                            }
                                
                        }
                            

                    }
                    self.timedShotPreTimer?.fire()
                
                
                
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                        timer.invalidate()
//                    }

 
            }

            


            
        }else if(startBtn.currentAttributedTitle?.string == "STOP"){
            if(self.timer != nil) {
                self.timer?.invalidate()
            }
            if(self.timedShotTimer != nil){
                self.timedShotTimer?.invalidate()
            }
            if(self.timedShotPreTimer != nil){
                self.timedShotPreTimer?.invalidate()
            }
            if(self.timedShotPauseTimer != nil){
                self.timedShotPauseTimer?.invalidate()
            }
            
            let copperFont = UIFont(name: "Copperplate", size: 24)!
            let boldCopperFontDescriptor = copperFont.fontDescriptor.withSymbolicTraits(.traitBold)!
            let boldCopperFont = UIFont(descriptor: boldCopperFontDescriptor, size: 24)

            let attributedString = NSAttributedString(string: "START", attributes: [.font: boldCopperFont])
            self.startBtn.setAttributedTitle(attributedString, for: .normal)
            self.hasStarted = false
            self.showingResult = false
            self.firstFrame = true
            self.countDownLabel.text = ""
            self.readyText.text = ""
            self.timerCount = 3
            self.preTimerHasRan = false
            self.shooterReadySoundPlaying = false


        }
    }
    
    
	override var shouldAutorotate: Bool {
		return false
	}
    func playSound() {
        var soundFile = ""
        if self.soundType == "Fun/Alien" {
            soundFile = "blaster"
        } else if self.soundType == "Steel"{
            soundFile = "steel"
        } else {
            soundFile = "sheels"
        }
        guard let url = Bundle.main.url(forResource: soundFile, withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
    func playBeep() {
        guard let url = Bundle.main.url(forResource: "beep", withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }

    func playShooterReady() {
        guard let url = Bundle.main.url(forResource: "shooter_ready", withExtension: "wav") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }

    
    func showResults(){
            let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "resultsView") as! ResultsViewController
            destinationVC.timeRecordsData = timeRecords
            present(destinationVC, animated: true, completion: nil)
    }
    
	func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		// Convert a captured image buffer to UIImage.
		guard let buffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
			print("could not get a pixel buffer")
			return
		}
		CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags.readOnly)
        //let image = CIImage(cvPixelBuffer: buffer).oriented(CGImagePropertyOrientation.right)
        let image = CIImage(cvPixelBuffer: buffer)
		let capturedImage = UIImage(ciImage: image)
		CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags.readOnly)
        if(hasStarted){
            
            if(firstFrame){
                //save first frame
                firstFrameImg = capturedImage
                firstFrame = false
            }else{
                if(self.playType == "10Shots" && !self.isShowingResetPane){
                    let detected = OpenCV.detectLaser(capturedImage, withH: s1)
                    //print("DETECTED \(detected)")
                    //let detected = 0
                    if (detected > 0 && !self.showingResult && self.shotsCount < 9) {
                        print("Detected")
                        self.isPlaying = false
                        self.showingResult = true
                        var tempImg : UIImage!
                        self.resultImg = OpenCV.detectRed(capturedImage, withOrigFrame: firstFrameImg, withXYArray: &XYArray, with: shotsCount)
                        shotsCount = shotsCount + 1
                        if (self.shotsCount > 0) { // super impose previous shots
                            tempImg = OpenCV.showPrevResults(capturedImage, withOrigFrame: self.resultImg, withLastShotIndex: self.shotsCount - 1, withXYArray: &self.XYArray)
                            self.resultImg = OpenCV.detectRed(capturedImage, withOrigFrame: tempImg, withXYArray: &XYArray, with: shotsCount - 1) // just redo previous call hence - 1
                            
                        }
                        
                        
                        print("\(XYArray)")
                        // Create a timer that fires every second and repeats indefinitely
                        var counterSec = 0
                        
                        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                            // Handle timer tick here
                            counterSec += 1
                            
                            
                            if(counterSec == 5) {
                                timer.invalidate()
                                //print("Timer stopped")
                            }
                            print("Countersec \(counterSec)")
                        }
                        timer.fire()
                        //                    // Schedule a task to stop the timer after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            timer.invalidate()
                            print("Timer stopped")
                            self.isPlaying = false
                            self.showingResult = false
                        }
                        
                    }else if(detected > 0 && !self.showingResult && self.shotsCount == 9){
                        print("Detected ALL 10")
                        self.isPlaying = false
                        self.showingResult = true
                        self.resultImg = OpenCV.detectRed(capturedImage, withOrigFrame: firstFrameImg, withXYArray: &XYArray, with: shotsCount) //call at least one more time
                        self.resultImg = OpenCV.show10Results(capturedImage, withOrigFrame: firstFrameImg, withXYArray: &XYArray)
                        shotsCount = shotsCount + 1
                        print("\(XYArray)")
                        // Create a timer that fires every second and repeats indefinitely
                        var counterSec = 0
                        
                        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                            // Handle timer tick here
                            counterSec += 1
                            
                            
                            if(counterSec == 5) {
                                timer.invalidate()
                                //print("Timer stopped")
                            }
                        }
                        timer.fire()
                        //                    // Schedule a task to stop the timer after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            timer.invalidate()
                            print("Timer stopped")
                            self.isPlaying = false
                            self.showingResult = false
                            self.hasStarted = false
                            let copperFont = UIFont(name: "Copperplate", size: 24)!
                            let boldCopperFontDescriptor = copperFont.fontDescriptor.withSymbolicTraits(.traitBold)!
                            let boldCopperFont = UIFont(descriptor: boldCopperFontDescriptor, size: 24)
                            
                            let attributedString = NSAttributedString(string: "START", attributes: [.font: boldCopperFont])
                            self.startBtn.setAttributedTitle(attributedString, for: .normal)
                            self.hasStarted = true // to keep detecting
                            self.showingResult = false
                            self.countDownLabel.text = ""
                            self.isShowingResetPane = true
                            self.firstFrame = true
                        }
                        
                    }
                    DispatchQueue.main.async(execute: {
                        if(self.showingResult != true) {
                            
                            //self.imageView.image = OpenCV.detectLaser2(capturedImage, withH: self.s1)//capturedImagee
                            if (self.shotsCount > 0) {
                                self.imageView.image = self.resultImg //OpenCV.showPrevResults(self.resultImg, withOrigFrame: self.firstFrameImg, withLastShotIndex: self.shotsCount - 1, withXYArray: &self.XYArray)
                                
                            } else {
                                self.imageView.image = capturedImage
                            }
                            //
                        } else {
                            self.imageView.image = self.resultImg
                            if(!self.isPlaying){
                                self.isPlaying = true
                                self.playSound()
                                
                            }
                        }
                        
                    })
                } else if(self.playType == "10Shots" && self.isShowingResetPane){
                    self.imageReset = OpenCV.detectReset(capturedImage, withOrigFrame: firstFrameImg)
                    let detect = OpenCV.detectResetShot(capturedImage, withOrigFrame: firstFrameImg)
                    if (detect == 1) {
                        self.firstFrame = true
                        self.isPlaying = false
                        self.hasStarted = false
                        print("REESET DETECTED")
                        DispatchQueue.main.async(execute: {
                            if(!self.isPlaying){
                                self.isPlaying = true
                                self.playSound()
                            }
                            self.startShoot(self.startBtn!)
                        })
                    }
                    DispatchQueue.main.async(execute: {
                        self.imageView.image = self.imageReset
                    })
                } else if (self.playType == "Unlimited Shots") {
                    let detected = OpenCV.detectLaser(capturedImage, withH: s1)
                    //print("DETECTED \(detected)")
                    //let detected = 0
                    if (detected > 0 && !self.showingResult){
                        print("Detected")
                        self.isPlaying = false
                        self.showingResult = true
                        
                        // Create a timer that fires every second and repeats indefinitely
                        if (!self.unliShotStarted) {
                            self.resultImg = OpenCV.detectRed(capturedImage, withOrigFrame: firstFrameImg, withXYArray: &XYArray, with: -1)
                            self.unliShotStarted = true
                            self.unliTempImg = firstFrameImg
                        } else {
                            self.resultImg = OpenCV.detectRed(capturedImage, withOrigFrame: firstFrameImg, withXYArray: &XYArray, with: 1)
                           
                            self.unliTempImg = OpenCV.showPrevResults(capturedImage, withOrigFrame: self.unliTempImg, withLastShotIndex: 1, withXYArray: &self.XYArray)
                            self.resultImg = OpenCV.detectRed(capturedImage, withOrigFrame: self.unliTempImg, withXYArray: &XYArray, with: 0) //
                        }
                        
                            
                        var counterSec = 0
                        
                        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                            // Handle timer tick here
                            counterSec += 1


                            if(counterSec == 5) {
                                timer.invalidate()
                                //print("Timer stopped")
                            }
                            print("Countersec \(counterSec)")
                        }
                        timer.fire()
    //                    // Schedule a task to stop the timer after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            timer.invalidate()
                            print("Timer stopped")
                            self.isPlaying = false
                            self.showingResult = false
                        }
                        
                    }
                    DispatchQueue.main.async(execute: {
                        if(self.showingResult != true) {
                            
                            //self.imageView.image = OpenCV.detectLaser2(capturedImage, withH: self.s1)//capturedImagee
                            if (self.unliShotStarted){
                                self.imageView.image = self.resultImg
                            } else {
                                self.imageView.image = capturedImage
                            }
                            
                        } else {
                            self.imageView.image = self.resultImg
                            if(!self.isPlaying){
                                self.isPlaying = true
                                self.playSound()

                            }
                        }
                            
                    })

                } else if (self.playType == "TimedShots"){
                    
                    if  (timerHasRan) {
                        let detected = OpenCV.detectLaser(capturedImage, withH: s1)
                        if (detected > 0 && !self.showingResult){
                            self.elapsedTime = ((CACurrentMediaTime() * 1000.0) - self.timeNow) / 1000
                            self.isPlaying = false
                            self.showingResult = true
                        
                            self.resultImg = OpenCV.detectRed(capturedImage, withOrigFrame: firstFrameImg, withXYArray: &XYArray, with: self.timedShotCount )
                            self.timedShotCount = self.timedShotCount + 1
                            if (self.timedShotCount > 0) { // super impose previous shots
                                var tempImg : UIImage!
                                tempImg = OpenCV.showPrevResults(capturedImage, withOrigFrame: self.resultImg, withLastShotIndex: self.timedShotCount - 1, withXYArray: &self.XYArray)
                                self.resultImg = OpenCV.detectRed(capturedImage, withOrigFrame: tempImg, withXYArray: &XYArray, with: self.timedShotCount - 1) // just redo previous call hence - 1
                                
                            }
                            print("\(XYArray)")
                            // Create a timer that fires every second and repeats indefinitely
                            var counterSec = 0
                            let elapsedFormatted = String(format: "%.2f", self.elapsedTime!)
                            timeRecords.append(self.elapsedTime)
                            print("\(timeRecords)")
                            DispatchQueue.main.async(execute: {
                                self.countDownLabel.text = "\(elapsedFormatted)"
                            })
                            self.timedShotTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {  timedShotTimer in
                                // Handle timer tick here
                                counterSec += 1


                                if(counterSec == 5) {
                                    self.timedShotTimer?.invalidate()
                                    //print("Timer stopped")
                                }
                            }
                            self.timedShotTimer?.fire()
                            // Schedule a task to stop the timer after 3 seconds
                            self.timerHasRan = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                self.timedShotTimer?.invalidate()
                                print("Timer stopped in TimedShot")
                                self.countDownLabel.text = ""
                                self.isPlaying = false
                                self.timerCount = 3
                                self.showingResult = false
                                self.preTimerHasRan = false
                            }

                        }
                        DispatchQueue.main.async(execute: {
                            if(self.showingResult != true) {
                                if (self.timedShotCount > 0) {
                                    self.imageView.image = self.resultImg
                                } else {
                                    self.imageView.image = capturedImage
                                }
                            } else {
                                print("TimedShotCount \(self.timedShotCount)")
                                if(self.timedShotCount >= self.numRounds){
                                    if(self.timer != nil) {
                                        self.timer?.invalidate()
                                    }
                                    if(self.timedShotTimer != nil){
                                        self.timedShotTimer?.invalidate()
                                    }
                                    if(self.timedShotPreTimer != nil){
                                        self.timedShotPreTimer?.invalidate()
                                    }
                                    if(self.timedShotPauseTimer != nil){
                                        self.timedShotPauseTimer?.invalidate()
                                    }
                                    
                                    let copperFont = UIFont(name: "Copperplate", size: 24)!
                                    let boldCopperFontDescriptor = copperFont.fontDescriptor.withSymbolicTraits(.traitBold)!
                                    let boldCopperFont = UIFont(descriptor: boldCopperFontDescriptor, size: 24)

                                    let attributedString = NSAttributedString(string: "Start", attributes: [.font: boldCopperFont])
                                    self.startBtn.setAttributedTitle(attributedString, for: .normal)
                                    self.hasStarted = false
                                    self.showingResult = false
                                    self.firstFrame = true
                                    self.countDownLabel.text = ""
                                    self.timerHasRan = false
                                    self.showResults()
                                }
                                self.imageView.image = self.resultImg
                                if(!self.isPlaying){
                                    self.isPlaying = true
                                    self.playSound()

                                }
                            }

                        })
                    }

                }
                
            }

        } else {
            DispatchQueue.main.async(execute: {
                //let detect = OpenCV.calib(capturedImage, withH: self.s1)
                self.imageView.image = capturedImage
            })
                    
        }
            



	}
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromViewControllerSegue" {
            if let destinationVC = segue.destination as? PreferenceViewController {

                destinationVC.previousScreen = "ViewController"
                print("FROM VIEWCONTROLLER \(self.playType)")
                destinationVC.playType = self.playType
                destinationVC.timedShots = self.timedShots ?? false
   

            }
        }
    }
    @IBAction func showPreference(_ sender: Any) {
        performSegue(withIdentifier: "fromViewControllerSegue", sender: self)
    }
    
}
