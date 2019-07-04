//
//  File.swift
//  Vitcord
//
//  Created by Carlos Roig on 16/11/18.
//  Copyright © 2018 Vitcord. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioEffect {
    var distortionPreset: AVAudioUnitDistortionPreset { get }
    var distortion: Float { get }
    var pitch: Float { get }
    var delay: Float { get }
    var reverb: Float {get}
}

extension AudioEffect {
    var distortionPreset: AVAudioUnitDistortionPreset { return .speechRadioTower }
    var distortion: Float { return 0.0 }
    var pitch: Float { return 0.0 }
    var delay: Float { return 0.0 }
    var reverb: Float { return 0.0 }
}

struct RobotAudioEffect: AudioEffect {
    
    var distortionPreset: AVAudioUnitDistortionPreset {
        return .speechRadioTower
    }
    
    var distortion: Float {
        return 18.5
    }
    
    var pitch: Float {
        return 435
    }
    
}

struct AlienAudioEffect: AudioEffect {
    
    var distortionPreset: AVAudioUnitDistortionPreset {
        return .multiEchoTight2
    }
    
    var distortion: Float {
        return 38.0
    }
    
    var pitch: Float {
        return 285
    }
}

struct DarthAudioEffect: AudioEffect {
    
    var distortionPreset: AVAudioUnitDistortionPreset {
        return .multiBrokenSpeaker
    }
    
    var distortion: Float {
        return 13.5
    }
    
    var pitch: Float {
        return -505.0
    }
    
}

struct MusicAudioEffect: AudioEffect {
    
    var delay: Float { return 0.2 }
    
    var reverb: Float { return 20.0 }

}

struct SquirrelAudioEffect: AudioEffect {
    
    var pitch: Float { return 1000.0 }
    
}

struct NoFilterAudioEffect: AudioEffect { }
