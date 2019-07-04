//
//  AudioModifier.swift
//  Vitcord
//
//  Created by Carlos Roig on 1/10/18.
//  Copyright © 2018 Vitcord. All rights reserved.
//

import Foundation
import AVFoundation

enum AudioEffectType: CaseIterable {
    case robot
    case alien
    case darth
    case squirrel
    case music
    case noFilter
    
    var text: String {
        switch self {
        case .squirrel:
            return "chipmunk"
        case .robot:
            return "robot"
        case .alien:
            return "alien"
        case .darth:
            return "darth"
        case .music:
            return "music"
        case .noFilter:
            return "no_filter"
        }
    }
}

class AudioEffectModifier : NSObject{
    
    fileprivate let engine = AVAudioEngine()
    fileprivate let player = AVAudioPlayerNode()
    fileprivate var outputRender: AVAudioFile!
    fileprivate var formatMusic: AVAudioFormat!
    fileprivate var sourceFileBase: AVAudioFile!

    
    @available(iOS 11.0, *)
    func modifyAudio(url: URL, outputURL: URL, effect: AudioEffect, success: @escaping (Bool) -> ()) {
        
        guard let sourceFileBase = try? AVAudioFile(forReading: url) else {
            success(false)
            return
        }
        
        self.sourceFileBase = sourceFileBase
        formatMusic = sourceFileBase.processingFormat
        
        setupEngine(effect: effect)
        setupOutputRender(url: outputURL)
        setupOfflineMode(success: success)
    }
    
    func setupEngine(effect: AudioEffect) {
        engine.attach(player)
        
        let reverb = AVAudioUnitReverb()
        reverb.loadFactoryPreset(.cathedral)
        reverb.wetDryMix = effect.reverb
        
        let delay = AVAudioUnitDelay()
        delay.delayTime = 1
        delay.wetDryMix = effect.delay
        delay.feedback = 60.0;
        delay.lowPassCutoff = 16000.0;
        
        let distortion = AVAudioUnitDistortion()
        distortion.loadFactoryPreset(effect.distortionPreset)
        distortion.wetDryMix = effect.distortion
        
        let pitch = AVAudioUnitTimePitch()
        pitch.pitch = effect.pitch
        
        engine.attach(distortion)
        engine.attach(pitch)
        engine.attach(reverb)
        engine.attach(delay)
        
        engine.connect(distortion, to: engine.mainMixerNode, format: formatMusic)
        engine.connect(pitch, to: distortion, format: formatMusic)
        engine.connect(reverb, to: pitch, format: formatMusic)
        engine.connect(delay, to:reverb, format: formatMusic)
        
        engine.connect(player, to: delay, format: formatMusic)
        
        player.scheduleFile(sourceFileBase, at: nil, completionHandler: nil)
    }

    
    // MARK: RENDER
    /*:
     - Creamos el fichero de salida para almacenar el audio renderizado
     */
    
    func setupOutputRender(url: URL) {
        
        guard let outputRender = try? AVAudioFile(forWriting: url, settings: sourceFileBase.fileFormat.settings) else {
            fatalError("Error")
        }
        
        self.outputRender = outputRender
    }
    
    @available(iOS 11.0, *)
    func setupOfflineMode(success: @escaping (Bool) -> () ) {
        
        let maxNumberOfFrames: AVAudioFrameCount = 4096
//        engine.prepare()
        guard let _ = try? engine.enableManualRenderingMode(.offline, format: formatMusic, maximumFrameCount: maxNumberOfFrames),
            let _ = try? engine.start() else {
                
                success(false)
                return
        }
        
        player.play()
        
        // crear buffer para renderizar offline
        let buffer = AVAudioPCMBuffer(pcmFormat: engine.manualRenderingFormat,
                                      frameCapacity: engine.manualRenderingMaximumFrameCount)!
        
        
        while engine.manualRenderingSampleTime < sourceFileBase.length {
            do {
                let framesToRender = min(buffer.frameCapacity, AVAudioFrameCount(sourceFileBase.length - engine.manualRenderingSampleTime))
                
                let status = try engine.renderOffline(framesToRender, to: buffer)
                switch status {
                case .success:
                    try outputRender.write(from: buffer)
                case .error:
                    success(false)
                default: break
                }
            } catch {
                fatalError("Error")
            }
        }
        
        player.stop()
        engine.stop()
        
        success(true)
    }
    
    deinit {
        print("DEINIT!!!!!")
    }
    
}

