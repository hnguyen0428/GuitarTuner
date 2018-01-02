//
//  AudioFFT.swift
//  GuitarTuner
//
//  Created by Hoang on 12/28/17.
//  Copyright © 2017 Hoang. All rights reserved.
//

import Accelerate

let accumulatorDataLength = 1 << 17

// Cut off frequency for second order filter
let centerFreq: Float = 90.0

// Cut off frequency for each guitar strings
// This is used to filter out the harmonics of the sound wave that
// could masquerade as the sound frequency when the string is played
// The cut off frequency is determined as the highest frequency that
// string could go to before it snaps (not the best method)
// Each of these frequencies is determined as the frequency of the note
// (+ 1.0 to compensate for inaccuracy of frequency detection)
// two steps up from the standard tuning
let sixthCutoffFreq: Float = 93.5
let fifthCutoffFreq: Float = 124.5
let fourthCutoffFreq: Float = 165.8
let thirdCutoffFreq: Float = 221.0
let secondCutoffFreq: Float = 278.2
let firstCutoffFreq: Float = 371.0


class AudioFFT {
    var fftsetup: FFTSetup!
    var complexA: DSPSplitComplex!
    
    var outFFTData: [Float]
    
    var halfSize: Int
    var log2n: Float
    var sampleRate: Float
    var sampleSize: Int
    
    // Used for second order low pass filter
    var a: [Float] = Array.init(repeating: 0.0, count: 2)
    var b: [Float] = Array.init(repeating: 0.0, count: 3)
    var mem1: [Float] = Array.init(repeating: 0.0, count: 4)
    var mem2: [Float] = Array.init(repeating: 0.0, count: 4)

    var nyquistFreq: Float {
        get {
            return sampleRate / 2.0
        }
    }
    
    init(sampleSize: Int, cutoffFreq: Float, sampleRate: Float = kSampleRate) {
        self.sampleSize = sampleSize
        log2n = log2f(Float(sampleSize))
        fftsetup = vDSP_create_fftsetup(UInt(log2n), FFTRadix(kFFTRadix2))
        halfSize = sampleSize/2
        outFFTData = Array.init(repeating: 0, count: halfSize)
        
        self.sampleRate = sampleRate
        computeSecondOrderFilter(cutoffFreq: cutoffFreq)
    }
    
    func computeFFT(_ monoSamples: [Float]) {
        var reals = [Float]()
        var imags = [Float]()
        var normFactor = Float(1.0) / Float(2*sampleSize)
        
        var samples = monoSamples
        
        for i in 0..<samples.count {
            samples[i] = processSecondOrderFilter(sampleValue: samples[i], mem: &mem1)
            samples[i] = processSecondOrderFilter(sampleValue: samples[i], mem: &mem2)
        }
        
        var window = hanWindow(size: samples.count)
        applyWindow(data: &samples, window: &window)
        
        for (index, value) in samples.enumerated() {
            if index % 2 == 0 {
                reals.append(value)
            } else {
                imags.append(value)
            }
        }
        
        self.complexA = DSPSplitComplex(realp: UnsafeMutablePointer(mutating: reals),
                                        imagp: UnsafeMutablePointer(mutating: imags))
        
        // Forward Fast Fourier Transform
        vDSP_fft_zrip(fftsetup, &(complexA!), 1, UInt(log2n), Int32(FFT_FORWARD))
        
        // Scale FFT
        vDSP_vsmul(complexA.realp, 1, &normFactor, complexA.realp, 1, vDSP_Length(sampleSize/2))
        vDSP_vsmul(complexA.imagp, 1, &normFactor, complexA.imagp, 1, vDSP_Length(sampleSize/2))
        
        // Get magnitudes data
        vDSP_zvmags(&(self.complexA!), 1, &self.outFFTData, 1, UInt(halfSize))
    }
    
    func hanWindow(size: Int) -> [Float] {
        var window = [Float]()
        for i in 0..<size {
            let value = 0.5 * ( 1.0 - cos( 2 * Double.pi * Double(i) / (Double(size) - 1.0) ) )
            window.append(Float(value))
        }
        
        return window
    }
    
    
    func applyWindow(data: inout [Float], window: inout [Float]) {
        for i in 0..<data.count {
            data[i] *= window[i]
        }
    }
    
    ///
    /// Credit to this blog
    /// http://blog.bjornroche.com/2012/07/frequency-detection-using-fft-aka-pitch.html
    /// for an example of how to implement second order filter
    ///
    func computeSecondOrderFilter(cutoffFreq: Float) {
        let w0 = Float(2.0 * Double.pi) * cutoffFreq/sampleRate
        let cosw0 = cos(w0)
        let sinw0 = sin(w0)
        let alpha = sinw0/2 * sqrt(2)
        let a0 = 1.0 + alpha

        self.a[0] = (-2 * cosw0) / a0
        self.a[1] = (1 - alpha) / a0
        self.b[0] = ((1 - cosw0)/2) / a0
        self.b[1] = (1 - cosw0) / a0
        self.b[2] = self.b[0]
    }

    // Give the new sample value after running through filter
    func processSecondOrderFilter(sampleValue x: Float, mem: inout [Float]) -> Float {
        let ret = b[0] * x + b[1] * mem[0] + b[2] * mem[1] - a[0] * mem[2]
        - a[1] * mem[3]

        mem[1] = mem[0]
        mem[0] = x
        mem[3] = mem[2]
        mem[2] = ret

        return ret
    }
    
    deinit {
        vDSP_destroy_fftsetup(fftsetup)
    }
}
