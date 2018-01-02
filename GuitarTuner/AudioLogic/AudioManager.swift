//
//  AudioManager.swift
//  GuitarTuner
//
//  Created by Hoang on 12/27/17.
//  Copyright © 2017 Hoang. All rights reserved.
//

import AVFoundation

let kSampleRate: Float = 44100.0

typealias AudioInputCallback = (
    _ timeStamp: Double,
    _ frameCount: Int,
    _ samples: [Float]
    ) -> Void



final class AudioManager: NSObject {
    let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    private(set) var audioUnit: AudioUnit!
    
    var sampleRate: Float
    var numberOfChannels: Int
    
    // Bus code as defined by OS
    let outputBus: UInt32 = 0
    let inputBus: UInt32 = 1
    
    let audioInputCallback: AudioInputCallback!
    
    // This callback is trigerred everytime an audio sample is received
    // by the audio unit
    private let recordingCallback: AURenderCallback = { (
        inRefCon,
        ioActionFlags,
        inTimeStamp,
        inBusNumber,
        frameCount,
        ioData ) -> OSStatus in
        
        let audioObject = unsafeBitCast(inRefCon, to: AudioManager.self)
        var osErr: OSStatus = noErr
        
        // set mData to nil, AudioUnitRender() should be allocating buffers
        var bufferList = AudioBufferList(
            mNumberBuffers: 1,
            mBuffers: AudioBuffer(
                mNumberChannels: UInt32(audioObject.numberOfChannels),
                mDataByteSize: 16,
                mData: nil
            )
        )
        
        osErr = AudioUnitRender(audioObject.audioUnit,
                                ioActionFlags,
                                inTimeStamp,
                                inBusNumber,
                                frameCount,
                                &bufferList)
        
        if osErr != noErr {
            print("AudioUnitRender error \(osErr)")
        }
        
        var monoSamples = [Float]() // Floating point sample
        let ptr = bufferList.mBuffers.mData?.assumingMemoryBound(to: Float.self)
        
        
        monoSamples.append(contentsOf: UnsafeBufferPointer(start: ptr, count: Int(frameCount)))
        // Pass data to TuningViewController using callback
        audioObject.audioInputCallback(inTimeStamp.pointee.mSampleTime / Double(audioObject.sampleRate),
                                      Int(frameCount),
                                      monoSamples)
        
        return 0
    }
    
    
    // The audioInputCallback passed in will get triggered everytime the
    // AudioUnit gets a sample of audio
    init(audioInputCallback callback: @escaping AudioInputCallback,
         sampleRate: Float = kSampleRate, numberOfChannels: Int = 1) {
        self.sampleRate = sampleRate
        self.numberOfChannels = numberOfChannels
        self.audioInputCallback = callback
    }
    
    private func setupAudioSession() {
        if !audioSession.availableCategories.contains(AVAudioSessionCategoryRecord) {
            print("Can't record")
            return
        }
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            
            try audioSession.setPreferredSampleRate(Double(self.sampleRate))
            
            try audioSession.setPreferredIOBufferDuration(0.058)
            
            audioSession.requestRecordPermission { hasPermission in
                if !hasPermission {
                    print("No permission to use mic")
                }
            }
        }
        catch {
            print("Error setting up audio session")
        }
    }
    
    
    private func setupAudioUnit() {
        var componentDesc = AudioComponentDescription(
            componentType: OSType(kAudioUnitType_Output),
            componentSubType: OSType(kAudioUnitSubType_RemoteIO),
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: 0,
            componentFlagsMask: 0
        )
        
        let component: AudioComponent! = AudioComponentFindNext(nil, &componentDesc)
        if component == nil {
            print("Couldn't find default component")
        }
        
        var osErr: OSStatus = noErr
        
        var tempAudioUnit: AudioUnit?
        osErr = AudioComponentInstanceNew(component, &tempAudioUnit)
        self.audioUnit = tempAudioUnit
        
        if osErr != noErr {
            print("Error creating new audio component")
        }
        
        var one: UInt32 = 1
        osErr = AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO,
                                     kAudioUnitScope_Input, inputBus, &one,
                                     UInt32(MemoryLayout<UInt32>.size))
        
        if osErr != noErr {
            print("Error setting audio unit's input property")
        }
        
        osErr = AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO,
                                     kAudioUnitScope_Output, outputBus, &one,
                                     UInt32(MemoryLayout<UInt32>.size))
        
        if osErr != noErr {
            print("Error setting audio unit's output property")
        }
        
        var asBasicDesc = AudioStreamBasicDescription(
            mSampleRate: Double(self.sampleRate),
            mFormatID: kAudioFormatLinearPCM, // Use uncompressed format so we can process the signal
            mFormatFlags: kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved,
            mBytesPerPacket: UInt32(self.numberOfChannels * MemoryLayout<UInt32>.size),
            mFramesPerPacket: 1,
            mBytesPerFrame: UInt32(self.numberOfChannels * MemoryLayout<UInt32>.size),
            mChannelsPerFrame: UInt32(self.numberOfChannels),
            mBitsPerChannel: 4 * 8,
            mReserved: 0
        )
        
        
        osErr = AudioUnitSetProperty(audioUnit,
                                     kAudioUnitProperty_StreamFormat,
                                     kAudioUnitScope_Input, outputBus,
                                     &asBasicDesc,
                                     UInt32(MemoryLayout<AudioStreamBasicDescription>.size))
        
        if osErr != noErr {
            print("Error setting audio unit's stream format output property \(osErr)")
        }
        
        osErr = AudioUnitSetProperty(audioUnit,
                                     kAudioUnitProperty_StreamFormat,
                                     kAudioUnitScope_Output,
                                     inputBus,
                                     &asBasicDesc,
                                     UInt32(MemoryLayout<AudioStreamBasicDescription>.size))
        
        if osErr != noErr {
            print("Error setting audio unit's stream format input property \(osErr)")
        }
        
        // This AURenderCallbackStruct will trigger recordingCallback everytime
        // it has a new sample
        var inputCallbackStruct =
            AURenderCallbackStruct(inputProc: recordingCallback,
                                   inputProcRefCon:
                UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        
        osErr = AudioUnitSetProperty(audioUnit,
                                     AudioUnitPropertyID(kAudioOutputUnitProperty_SetInputCallback),
                                     AudioUnitScope(kAudioUnitScope_Global),
                                     inputBus,
                                     &inputCallbackStruct,
                                     UInt32(MemoryLayout<AURenderCallbackStruct>.size))
        
        if osErr != noErr {
            print("Error with callback \(osErr)")
        }
        
        // Ask CoreAudio to allocate buffers on render.
        osErr = AudioUnitSetProperty(audioUnit,
                                     AudioUnitPropertyID(kAudioUnitProperty_ShouldAllocateBuffer),
                                     AudioUnitScope(kAudioUnitScope_Output),
                                     inputBus,
                                     &one,
                                     UInt32(MemoryLayout<UInt32>.size))
        
        if osErr != noErr {
            print("Error with AudioUnitSetProperty \(osErr)")
        }
    }
    
    func startRecording() {
        do {
            if self.audioUnit == nil {
                // Setup the audio unit
                setupAudioSession()
                setupAudioUnit()
            }
            
            // Start to record
            try self.audioSession.setActive(true)
            var osErr: OSStatus = 0
            osErr = AudioUnitInitialize(self.audioUnit)
            
            if osErr != noErr {
                print("Error initializing audio unit")
            }
            
            osErr = AudioOutputUnitStart(self.audioUnit)

            if osErr != noErr {
                print("Error starting audio output")
            }
        }
        catch {
            print("START RECORDING ERROR:\n\(error)")
        }
    }
    
    func stopRecording() {
        do {
            var osErr: OSStatus = 0
            
            osErr = AudioUnitUninitialize(self.audioUnit)
            
            if osErr != noErr {
                print("Error uninitializing audio unit")
            }
            
            try self.audioSession.setActive(false)
        } catch {
            print("STOP RECORDING ERROR:\n\(error)")
        }
    }
    
}
