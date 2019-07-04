//
//  AudioVideoEffectComposer.swift
//  Vitcord
//
//  Created by Carlos Roig on 4/10/18.
//  Copyright © 2018 Vitcord. All rights reserved.
//

import Foundation
import AVFoundation

class AudioEffectVideoComposer {
    
    var originalVideoURL: URL!
    private var modifiedVideoURLs = [AudioEffectType:URL]()
    
    @available(iOS 11.0, *)
    func modifyVideo(url: URL, effectType: AudioEffectType, completion: @escaping (URL?) -> ()) {
        
        guard let modifiedVideoURL = modifiedVideoURLs[effectType] else {
            let audioExtractor = AudioExtractor()
            let extractedAudioURL = URL.createFileURL(at: NSTemporaryDirectory(), pathExtension: "m4a")
            originalVideoURL = url
            audioExtractor.writeAudioTrack(from: originalVideoURL, outputURL: extractedAudioURL) { [weak self] (success) in
                guard success,
                      let sSelf = self else {
                    completion(nil)
                    return
                }
               
                sSelf.addEffect(url: extractedAudioURL, effectType: effectType, completion: { [weak self] (modifiedURL) in
                    guard let modifiedURL = modifiedURL,
                          let sSelf = self else {
                        completion(nil)
                        return
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        sSelf.mixVideo(videoURL: sSelf.originalVideoURL, audioURL: modifiedURL, effectType: effectType, completion:completion)
                    })
                })
            }
            
            return
        }
        
        completion(modifiedVideoURL)
    }
    @available(iOS 11.0, *) 
    private func addEffect(url: URL, effectType: AudioEffectType, completion: @escaping (URL?) -> ()) {
        let modifiedAudioURL = URL.createFileURL(at: NSTemporaryDirectory(), pathExtension: "m4a")

        let audioEffectModifier = AudioEffectModifier()
        let effect = AudioEffectFactory.audioEffect(type: effectType)
        
        audioEffectModifier.modifyAudio(url: url, outputURL:modifiedAudioURL, effect: effect) { (success) in
            guard success else {
                completion(nil)
                return
            }
            completion(modifiedAudioURL)
        }
    }
    
    private func mixVideo(videoURL:URL, audioURL: URL, effectType:AudioEffectType, completion: @escaping (URL?) -> ()) {
        let mixedVideoURL = URL.createFileURL()
        let videoAudioMixer = VideoAudioMixer()
        videoAudioMixer.mixVideo(videoURL: videoURL, audioURL: audioURL, outputURL: mixedVideoURL) { [weak self](success) in
            guard success else {
                completion(nil)
                return
            }
            self?.modifiedVideoURLs[effectType] = mixedVideoURL
            completion(mixedVideoURL)
        }
    }
}
