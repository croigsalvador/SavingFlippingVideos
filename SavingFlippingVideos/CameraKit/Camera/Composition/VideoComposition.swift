//
//  VideoComposition.swift
//  EasyCamera
//
//  Created by Carlos Roig on 17/1/18.
//  Copyright © 2018 CRS. All rights reserved.
//

import Foundation
import AVKit
import Alamofire

typealias VideoResult = Result<URL,Error>

class VideoComposition: NSObject {
    
    func videoMix(of videoURLS:[URL], in outputURL:URL, with completion: @escaping (VideoResult) -> ()) {
    
        let composition = AVMutableComposition()
        var currentTime = kCMTimeZero
        
        let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID())
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())

        for (index, videoURL) in videoURLS.enumerated() {
            let asset = AVURLAsset(url: videoURL) as AVAsset
            
            guard  let assetVideoTrack = asset.tracks(withMediaType: AVMediaType.video).first,
                let assetAudioTrack = asset.tracks(withMediaType: AVMediaType.audio).first,
                let _ = try? compositionVideoTrack?.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: asset.duration), of: assetVideoTrack, at: currentTime),
                let _ = try? compositionAudioTrack?.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: asset.duration), of: assetAudioTrack, at: currentTime)
                else {
                    continue
            }
            
            compositionVideoTrack?.preferredTransform = assetVideoTrack.preferredTransform
            if index < videoURLS.count - 1 {
                currentTime = CMTimeAdd(currentTime, asset.duration)
            }
        }
        
        let fileManager = FileManager.default
        let start = CMTimeMake(0, 1)
        let range = CMTimeRangeMake(start, composition.duration)
        
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: composition)
        var preset: String = AVAssetExportPresetPassthrough
        if compatiblePresets.contains(AVAssetExportPreset1920x1080) { preset = AVAssetExportPreset1920x1080 }
        
        guard
            let exportSession = AVAssetExportSession(asset: composition, presetName: preset),
            exportSession.supportedFileTypes.contains(AVFileType.mp4) else {
                return
        }
        
        
        exportSession.outputFileType = AVFileType.mp4
        exportSession.outputURL = outputURL
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.timeRange = range
        
        exportSession.exportAsynchronously { () -> Void in
            switch exportSession.status {
            case .completed:
                completion(VideoResult.success(outputURL))

            case .failed:
                guard let _ = try? fileManager.removeItem(at: outputURL) else {
                        completion(VideoResult.failure(NSError.init(domain: "Error removing file", code: 232, userInfo: nil)))
                    return
                }
                completion(VideoResult.failure(NSError.init(domain: "Error exporting file", code: 233, userInfo: nil)))

            default:
                completion(VideoResult.success(nil))
            }
        }
    }
}
