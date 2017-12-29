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

var totalMonoSamples: [Float] = [Float]()
var totalFrameCount: Int = 0

func accumulateSamples(frameCount: Int, samples: [Float]) {
    totalMonoSamples.append(contentsOf: samples)
    totalFrameCount += frameCount
}

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
            accumulateSamples(frameCount: frameCount, samples: samples)
            self.processAudio(timeStamps: timeStamps, frameCount: totalFrameCount,
                              monoSamples: totalMonoSamples)
        }
        
        audioManager = AudioManager(audioInputCallback: audioCallback,
                                    sampleRate: kSampleRate,
                                    numberOfChannels: 1)
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
    
    func processAudio(timeStamps: Double, frameCount: Int, monoSamples: [Float]) {
        // Number of frames is not large enough
        if frameCount < accumulatorDataLength {
            return
        }
        
        let audioFFT = AudioFFT(sampleSize: frameCount)
        audioFFT.computeFFT(monoSamples)
        
        let outFFTData = audioFFT.outFFTData
        
        // Find the bin with the maximum magnitude
        var maxIndex: Int = 0
        _ = maxOfFloatArray(array: outFFTData, maxIndex: &maxIndex)
        
        // Need to low pass filter
        let fftDataSize = frameCount / 2
        let audioFrequency = Float(maxIndex) / Float(fftDataSize) * audioFFT.nyquistFreq
        print("Max Frequency: \(audioFrequency) Hz")
        
        resetTotalSamples()
    }
    
}



func resetTotalSamples() {
    totalMonoSamples.removeAll()
    totalFrameCount = 0
}

func maxOfFloatArray(array: [Float], maxIndex: inout Int) -> Float {
    var mIndex: Int = 0
    var maxValue: Float = 0.0
    for (index, value) in array.enumerated() {
        if value > maxValue {
            mIndex = index
            maxValue = value
        }
    }
    
    maxIndex = mIndex
    return maxValue
}

