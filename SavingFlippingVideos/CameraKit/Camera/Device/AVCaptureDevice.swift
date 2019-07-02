//
//  AVCaptureDevice.swift
//  EasyCamera
//
//  Created by Carlos Roig on 18/1/18.
//  Copyright © 2018 CRS. All rights reserved.
//

import Foundation
import AVFoundation

extension AVCaptureDevice {
    
    static func camera(_ position: AVCaptureDevice.Position ) -> AVCaptureDevice? {
        var camera: AVCaptureDevice?
        if #available(iOS 10.0, *) {
          camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position:position)
        } else {
            return nil
        }
        camera?.activeVideoMinFrameDuration = CMTimeMake(1, 30)
        return camera
    }

    static func microphone() -> AVCaptureDevice? {
        if #available(iOS 10.0, *) {
            return AVCaptureDevice.default(.builtInMicrophone, for: AVMediaType.audio, position: .unspecified)
        } else {
            return nil
        }
    }

    static func configure(_ device: AVCaptureDevice) {
        guard let _ = try? device.lockForConfiguration() else { return }
        if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
        if device.isLowLightBoostSupported {
                device.automaticallyEnablesLowLightBoostWhenAvailable = true
            }
            
        device.unlockForConfiguration()
    }
    
    func configureFocus(at focusPoint: CGPoint) {
        guard let _ = try? lockForConfiguration() else { return }
        
        if isFocusPointOfInterestSupported == true {
            focusPointOfInterest = focusPoint
            focusMode = .autoFocus
        }
        exposurePointOfInterest = focusPoint
        exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
        
        unlockForConfiguration()
    }
    
    func configureZoom(with scale:CGFloat) {
        guard let _ = try? lockForConfiguration() else { return }
        
        videoZoomFactor = scale
        
        unlockForConfiguration()
    }
    
    func torch(on: Bool) {
        guard let _ = try? lockForConfiguration() else { return }
        if on {
            torchMode = .on
        } else {
            torchMode = .off
        }
        unlockForConfiguration()
    }
    
}
