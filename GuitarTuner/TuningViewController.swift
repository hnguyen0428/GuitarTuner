//
//  TuningViewController.swift
//  GuitarTuner
//
//  Created by Hoang on 12/27/17.
//  Copyright © 2017 Hoang. All rights reserved.
//

import UIKit
import AVFoundation
import Accelerate

class TuningViewController: UIViewController {
    
    var tuningView: TuningView!
    var audioManager: AudioManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = UIColor.darkGray
        setupTuningView()
        
        let audioCallback: AudioInputCallback = { (timeStamps, frameCount, samples) -> Void in
            // TODO: Do FFT in order to figure out the frequency
        }
        
        audioManager = AudioManager(audioInputCallback: audioCallback)
        audioManager.startRecording()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func setupTuningView() {
        let width = view.frame.width * 0.70
        let height = view.frame.height * 0.35
        let y = view.frame.height * 0.50
        let frame = CGRect(x: 0, y: y, width: width, height: height)
        
        tuningView = TuningView(frame: frame, tuningType: "EADGBE")
        tuningView.center.x = view.center.x
        view.addSubview(tuningView)
    }
    
}

