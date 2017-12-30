//
//  TuningViewController.swift
//  GuitarTuner
//
//  Created by Hoang on 12/27/17.
//  Copyright © 2017 Hoang. All rights reserved.
//

import UIKit

var totalMonoSamples: [Float] = [Float]()
var totalFrameCount: Int = 0

func accumulateSamples(frameCount: Int, samples: [Float]) {
    totalMonoSamples.append(contentsOf: samples)
    totalFrameCount += frameCount
}

class TuningViewController: UIViewController, TuningViewDelegate {
    
    var tuningView: TuningView!
    var audioManager: AudioManager!
    
    var chosenTuning: String? = nil
    
    var tuner: Tuner? = nil
    var cutoffFreq: Float = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = UIColor.darkGray
        setupTuningView()
        
        let audioCallback: AudioInputCallback = { (timeStamps, frameCount, samples) -> Void in
            accumulateSamples(frameCount: frameCount, samples: samples)
            self.processAudio(timeStamps: timeStamps, frameCount: totalFrameCount,
                              monoSamples: totalMonoSamples)
        }
        
        audioManager = AudioManager(audioInputCallback: audioCallback,
                                    sampleRate: kSampleRate,
                                    numberOfChannels: 1)
    }
    
    func setupTuningView() {
        let width = view.frame.width * 0.70
        let height = view.frame.height * 0.35
        let y = view.frame.height * 0.50
        let frame = CGRect(x: 0, y: y, width: width, height: height)
        
        tuningView = TuningView(frame: frame, tuningType: chosenTuning!)
        tuningView.center.x = view.center.x
        tuningView.delegate = self
        view.addSubview(tuningView)
    }
    
    func processAudio(timeStamps: Double, frameCount: Int, monoSamples: [Float]) {
        // Number of frames is not large enough
        if frameCount < accumulatorDataLength {
            return
        }
        
        let audioFFT = AudioFFT(sampleSize: frameCount, cutoffFreq: firstCutoffFreq)
        audioFFT.computeFFT(monoSamples)
        
        let outFFTData = audioFFT.outFFTData
        
        // Find the bin with the maximum magnitude
        var maxIndex: Int = 0
        _ = maxOfFloatArray(array: outFFTData, maxIndex: &maxIndex)
        
        // Need to low pass filter
        let fftDataSize = frameCount / 2
        let audioFrequency = Float(maxIndex) / Float(fftDataSize) * audioFFT.nyquistFreq
        
        resetTotalSamples()
        
        if let tuner = self.tuner {
            let inTuned = tuner.inTuned(freq: audioFrequency)
            print("Max Frequency: \(audioFrequency) Hz")
            print("Tuning note: \(tuner.note)")
            print("Tuning note frequency: \(tuner.noteFrequency) Hz")
            print("In tuned: \(inTuned)")
        }
    }
    
    func didSelect(note: String, strInd: Int) {
        tuner = Tuner(note: note, mul: 2)
        
        switch strInd {
        case 1:
            cutoffFreq = firstCutoffFreq
        case 2:
            cutoffFreq = secondCutoffFreq
        case 3:
            cutoffFreq = thirdCutoffFreq
        case 4:
            cutoffFreq = fourthCutoffFreq
        case 5:
            cutoffFreq = fifthCutoffFreq
        case 6:
            cutoffFreq = sixthCutoffFreq
        default:
            break
        }
        
        audioManager.startRecording()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioManager.stopRecording()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

