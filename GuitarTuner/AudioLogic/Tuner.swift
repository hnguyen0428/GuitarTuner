//
//  Tuner.swift
//  GuitarTuner
//
//  Created by Hoang on 12/28/17.
//  Copyright © 2017 Hoang. All rights reserved.
//

import Foundation

// Guitar sounds won't go higher than this
let cutoffFreq: Float = 4100.0

class Tuner {
    
    static let range: Float = 0.38
    
    var noteFundFrequency: Float
    var noteFrequency: Float
    var note: String
    
    init(note: String, mul: Int = 0) {
        self.note = note
        
        switch note {
        case "C":
            self.noteFundFrequency = 16.351
        case "C#":
            self.noteFundFrequency = 17.324
        case "D":
            self.noteFundFrequency = 18.354
        case "D#":
            self.noteFundFrequency = 19.445
        case "E":
            self.noteFundFrequency = 20.601
        case "F":
            self.noteFundFrequency = 21.827
        case "F#":
            self.noteFundFrequency = 23.124
        case "G":
            self.noteFundFrequency = 24.499
        case "G#":
            self.noteFundFrequency = 25.956
        case "A":
            self.noteFundFrequency = 27.50
        case "A#":
            self.noteFundFrequency = 29.135
        case "B":
            self.noteFundFrequency = 30.868
        default:
            self.noteFundFrequency = 0.0
            print("Invalid note")
        }
        
        noteFrequency = self.noteFundFrequency * Float(1 << mul)
    }
    
    /// Return: float, difference in frequency,
    func inTuned(freq: Float) -> Bool {
        var currFreq = noteFundFrequency
        
        // Used to determine which harmonic the note is closest to
        var allHarmonicsFreq: [Float:Float] = [Float:Float]()
        var tuned = false
        
        // Try to find if the frequency played is part of the note's harmonic
        while(currFreq < cutoffFreq) {
            allHarmonicsFreq[currFreq] = abs(currFreq - freq)
            if within(float1: currFreq, float2: freq, range: Tuner.range) {
                tuned = true
                break
            }
            currFreq *= 2
        }
        
        var minValue: Float = allHarmonicsFreq.first!.value
        var closestNoteFrequency: Float = allHarmonicsFreq.first!.key
        for (key, value) in allHarmonicsFreq {
            if minValue > value {
                minValue = value
                closestNoteFrequency = key
            }
        }
        
        self.noteFrequency = closestNoteFrequency
        return tuned
    }
    
    func within(float1: Float, float2: Float, range: Float) -> Bool {
        return abs(float1 - float2) < range
    }
    
}

