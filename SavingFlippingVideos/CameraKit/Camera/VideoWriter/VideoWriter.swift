//
//  VideoWriter.swift
//  EasyCamera
//
//  Created by Carlos Roig on 7/1/18.
//  Copyright © 2018 CRS. All rights reserved.
//

import AVFoundation
import AssetsLibrary
import UIKit
import Foundation

class VideoWriter : NSObject {
    var fileWriter: AVAssetWriter!
    var videoInput: AVAssetWriterInput!
    var audioInput: AVAssetWriterInput!
    var isVideoFirstFrame = false
    var startTime: Date?
    
    init(fileUrl:URL!, height: CGFloat, width: CGFloat){
        fileWriter = try? AVAssetWriter(outputURL: fileUrl, fileType: AVFileType.mp4)
            let videoOutputSettings: Dictionary<String, AnyObject> = [
                AVVideoCodecKey : AVVideoCodecH264 as AnyObject,
                AVVideoWidthKey : height as AnyObject,
                AVVideoHeightKey : width as AnyObject
            ]
            
            videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoOutputSettings)
            videoInput.expectsMediaDataInRealTime = true
            videoInput.transform = CGAffineTransform(rotationAngle: .pi/2)
            fileWriter.add(videoInput)
            
            let audioOutputSettings: Dictionary<String, AnyObject> = [
                AVFormatIDKey : Int(kAudioFormatMPEG4AAC) as AnyObject,
                AVNumberOfChannelsKey : 1 as AnyObject,
                AVSampleRateKey : AVAudioSession.sharedInstance().sampleRate as AnyObject,
                AVEncoderBitRateKey : 128000 as AnyObject
            ]
            audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutputSettings)
            audioInput.expectsMediaDataInRealTime = true
            fileWriter.add(audioInput)
    }
    
    func write(_ sample: CMSampleBuffer, isVideo: Bool){
        if CMSampleBufferDataIsReady(sample) {
            if isVideo  {
                isVideoFirstFrame = true
            }
            
            if isVideoFirstFrame {
                if fileWriter.status == AVAssetWriter.Status.unknown {
                    let startTime = CMSampleBufferGetPresentationTimeStamp(sample)
                    self.startTime = Date()
                    fileWriter.startWriting()
                    fileWriter.startSession(atSourceTime: startTime)
                }
                if fileWriter.status == AVAssetWriter.Status.failed {
                    return
                }
                if isVideo {
                    if videoInput.isReadyForMoreMediaData {
                        videoInput.append(sample)
                    }
                }else {
                    if audioInput.isReadyForMoreMediaData {
                        audioInput.append(sample)
                    }
                }
            }
        }
    }
    
    func finish(_ callback: @escaping (TimeInterval) -> ()){
        guard let startTime = startTime else {
            callback(0.0)
            return
        }
        fileWriter.finishWriting {
            callback(Date().timeIntervalSince(startTime))
        }
    }
}
