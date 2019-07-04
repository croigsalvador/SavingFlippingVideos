//
//  AudioExtractor.swift
//  Vitcord
//
//  Created by Carlos Roig on 4/10/18.
//  Copyright © 2018 Vitcord. All rights reserved.
//

import Foundation
import AVFoundation

struct AudioExtractor {
    
    func writeAudioTrack(from url:URL, outputURL: URL, success: @escaping (Bool) -> ()) {
        
        guard let audioAsset = audioAsset(from:AVAsset(url: url)) else {
            success(false)
            return
        }
        write(asset: audioAsset, outputURL: outputURL, success: success)
    }
    
    private func write(asset: AVAsset, outputURL: URL, success: @escaping (Bool) -> ()) {
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            success(false)
            return
        }
        
        exportSession.outputFileType = .m4a
        exportSession.outputURL = outputURL
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                success(true)
            case .unknown, .waiting, .exporting, .failed, .cancelled:
                success(false)
            }
        }
    }
    
    private func audioAsset(from asset: AVAsset) -> AVAsset? {
        // Create a new container to hold the audio track
        let composition = AVMutableComposition()
        // Create an array of audio tracks in the given asset
        // Typically, there is only one
        let audioTracks = asset.tracks(withMediaType: .audio)
        
        // Iterate through the audio tracks while
        // Adding them to a new AVAsset
        for track in audioTracks {
            guard  let compositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
                continue
            }
            guard let _ = try? compositionTrack.insertTimeRange(track.timeRange, of: track,at: track.timeRange.start) else {
                return nil
            }
        }
        
        return composition
    }
}
