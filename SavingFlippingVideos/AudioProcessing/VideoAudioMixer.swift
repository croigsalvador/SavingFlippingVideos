//
//  AudioVideoMixer.swift
//  Vitcord
//
//  Created by Carlos Roig on 3/10/18.
//  Copyright © 2018 Vitcord. All rights reserved.
//

import Foundation
import AVFoundation

class VideoAudioMixer {
    
    // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
    let mixComposition = AVMutableComposition()
    
    func mixVideo(videoURL: URL, audioURL: URL, outputURL: URL, success:@escaping (Bool) ->() ) {
        
        let videoAsset = AVAsset(url: videoURL)
        let audioAsset = AVAsset(url: audioURL)
        
        // 2 - Create two video tracks
        guard let videoTrack = mixComposition.addMutableTrack(withMediaType:.video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            else {
                print("Failed to load first track")
                return
        }
        do {
            
            guard let assetVideoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).last else {
                success(false)
                return
            }
            
            try videoTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: assetVideoTrack, at: CMTime.zero)
            
            videoTrack.preferredTransform = assetVideoTrack.preferredTransform
            
        } catch {
            success(false)
            print("Failed to load first track")
            return
        }
        
        
        // 3 - Audio track
        let audioTrack = mixComposition.addMutableTrack(withMediaType:.audio, preferredTrackID: 0)
        do {
            try audioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: audioAsset.tracks(withMediaType: AVMediaType.audio)[0], at: CMTime.zero)
        } catch {
            success(false)
            print("Failed to load Audio track")
        }
        
        
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: mixComposition)
        var preset: String = AVAssetExportPresetPassthrough
        if compatiblePresets.contains(AVAssetExportPreset1920x1080) { preset = AVAssetExportPreset1920x1080 }
        
        
        // 5 - Create Exporter
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: preset) else {
            success(false)
            print("Failed to load eXPORTER ")
            return
        }
        
        exporter.outputFileType = .mp4
        exporter.outputURL = outputURL
        exporter.shouldOptimizeForNetworkUse = true
        
        // 6 - Perform the Export
        exporter.exportAsynchronously {
            switch exporter.status {
            case .completed:
                success(true)
            case .unknown, .waiting, .exporting, .failed, .cancelled:
                success(false)
            }
        }
        
    }
    
    deinit {
        print("DEINIT OF VIDEOMIXER ")
    }
}
