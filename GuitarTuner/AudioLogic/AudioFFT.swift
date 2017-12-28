//
//  AudioFFT.swift
//  GuitarTuner
//
//  Created by Hoang on 12/28/17.
//  Copyright © 2017 Hoang. All rights reserved.
//

import Accelerate

let accumulatorDataLength = 32768

class AudioFFT {
    var fftsetup: FFTSetup!
    var complexA: DSPSplitComplex!
    
    var outFFTData: [Float]
    
    var halfSize: Int
    var log2n: Float
    var sampleRate: Float
    var sampleSize: Int

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
    }
    
    func computeFFT(_ monoSamples: [Float]) {
        var reals = [Float]()
        var imags = [Float]()
        var mFFTNormFactor = Float(1.0) / Float(2*sampleSize)
        
        for (index, value) in monoSamples.enumerated() {
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
    
    deinit {
        vDSP_destroy_fftsetup(fftsetup)
    }
}
