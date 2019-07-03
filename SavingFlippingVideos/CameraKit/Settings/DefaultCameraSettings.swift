//
//  DefaultCameraSettings.swift
//  EasyCamera
//
//  Created by Carlos Roig on 18/1/18.
//  Copyright © 2018 CRS. All rights reserved.
//

import Foundation
import AVFoundation

struct DefaultCameraSettings: CameraSettings {
    
    var camera: AVCaptureDevice?
    
    init(_ camera: AVCaptureDevice? = AVCaptureDevice.camera(.front)) {
        self.camera = camera
    }
    
    func setCamera(_ camera: AVCaptureDevice) -> DefaultCameraSettings {
        return DefaultCameraSettings(camera)
    }
}
