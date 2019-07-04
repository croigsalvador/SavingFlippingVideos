//
//  AudioEffectFactory.swift
//  Vitcord
//
//  Created by Carlos Roig on 16/11/18.
//  Copyright © 2018 Vitcord. All rights reserved.
//

import Foundation

struct AudioEffectFactory {
    
    static func audioEffect(type: AudioEffectType) -> AudioEffect {
        switch type {
        case .robot:
            return RobotAudioEffect()
        case .alien:
            return AlienAudioEffect()
        case .darth:
            return DarthAudioEffect()
        case .squirrel:
            return SquirrelAudioEffect()
        case .music:
            return MusicAudioEffect()
        case .noFilter:
            return NoFilterAudioEffect()
        }
    }
}
