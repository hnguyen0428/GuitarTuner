//
//  AudioFFT.swift
//  GuitarTuner
//
//  Created by Hoang on 12/28/17.
//  Copyright © 2017 Hoang. All rights reserved.
//

import Accelerate

let accumulatorDataLength = 65536

// Cut off frequency for second order filter
let centerFreq: Float = 330.0

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
    
    init(sampleSize: Int, sampleRate: Float = kSampleRate) {
        self.sampleSize = sampleSize
        log2n = log2f(Float(sampleSize))
        fftsetup = vDSP_create_fftsetup(UInt(log2n), FFTRadix(kFFTRadix2))
        halfSize = sampleSize/2
        outFFTData = Array.init(repeating: 0, count: halfSize)
        
        self.sampleRate = sampleRate
        
        computeSecondOrderFilter()
    }
    
    func computeFFT(_ monoSamples: [Float]) {
        var reals = [Float]()
        var imags = [Float]()
        var mFFTNormFactor = Float(1.0) / Float(2*sampleSize)
        
        // Make a copy so we can low pass data
        var samples = monoSamples
        
        // Low pass data
        for i in 0..<samples.count {
            samples[i] = processSecondOrderFilter(sampleValue: samples[i], mem: &mem1)
            samples[i] = processSecondOrderFilter(sampleValue: samples[i], mem: &mem2)
        }
        
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
        vDSP_vsmul(complexA.realp, 1, &mFFTNormFactor, complexA.realp, 1, vDSP_Length(sampleSize/2))
        vDSP_vsmul(complexA.imagp, 1, &mFFTNormFactor, complexA.imagp, 1, vDSP_Length(sampleSize/2))
        
        // Get magnitudes data
        vDSP_zvmags(&(self.complexA!), 1, &self.outFFTData, 1, UInt(halfSize))
    }
    
    
    ///
    /// Credit to this blog
    /// http://blog.bjornroche.com/2012/07/frequency-detection-using-fft-aka-pitch.html
    /// for an example of how to implement second order filter
    ///
    func computeSecondOrderFilter() {
        let w0 = Float(2.0 * Double.pi) * centerFreq/sampleRate
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
