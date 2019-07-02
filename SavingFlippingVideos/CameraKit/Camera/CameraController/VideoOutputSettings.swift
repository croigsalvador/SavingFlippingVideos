//
//  VideoOutputSettings.swift
//  Vitcord
//
//  Created by Juan Garcia on 17/10/18.
//  Copyright © 2018 Vitcord. All rights reserved.
//

import AVFoundation
import GPUImage


struct VideoOutputSettings {
    
    let videoCodecKey: String
    let outputSize: VideoOutputSize
    
    var settings: Dictionary<String, AnyObject> {
        return [
            AVVideoCodecKey : videoCodecKey as AnyObject,
            AVVideoWidthKey : outputSize.width as AnyObject,
            AVVideoHeightKey : outputSize.height as AnyObject
        ]
    }
    
    static func vitcordVideoOutputSettings() -> VideoOutputSettings {
        return VideoOutputSettings(videoCodecKey: AVVideoCodecH264,
                                   outputSize: VideoOutputSize.vitcordVideoSize())
    }
}

struct VideoOutputSize {
    
    let height: CGFloat
    let width: CGFloat
    
    var gpuImageSize: Size {
        return Size(width: Float(self.width), height: Float(height))
    }
    
    static func vitcordVideoSize() -> VideoOutputSize {
        return VideoOutputSize(height: 768.0, width: 432.0)
    }
}
