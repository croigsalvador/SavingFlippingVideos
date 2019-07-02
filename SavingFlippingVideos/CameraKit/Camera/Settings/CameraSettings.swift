//
//  CameraSettings.swift
//  EasyCamera
//
//  Created by Carlos Roig on 18/1/18.
//  Copyright © 2018 CRS. All rights reserved.
//

import Foundation

import AVFoundation

public protocol CameraSettings {
    var camera: AVCaptureDevice? { get }
    var frontCamera: AVCaptureDevice? { get }
    var backCamera: AVCaptureDevice? { get }
    var microphone: AVCaptureDevice? { get }
    var videoInput: AVCaptureInput? { get }
    var audioInput: AVCaptureInput? { get }
    func setCamera(_ camera: AVCaptureDevice) -> Self
    
    func switchCamera(currentDevice: AVCaptureDevice) -> AVCaptureDevice
}

extension CameraSettings {
    
    var frontCamera: AVCaptureDevice? {
        return AVCaptureDevice.camera(.front)
    }
    
    var microphone: AVCaptureDevice? {
        return AVCaptureDevice.microphone()
    }
    
    var backCamera: AVCaptureDevice? {
        return AVCaptureDevice.camera(.back)
    }
    
    var videoInput: AVCaptureInput? {
        guard let camera = camera,
            let captureDeviceInput = try? AVCaptureDeviceInput(device:camera) else {
            return nil
        }
        return captureDeviceInput
    }
    
    var audioInput: AVCaptureInput? {
        guard let microphone = microphone,
            let captureDeviceInputAudio = try? AVCaptureDeviceInput(device:microphone) else {
                return nil
        }
        return captureDeviceInputAudio
    }

    func switchCamera(currentDevice: AVCaptureDevice) -> AVCaptureDevice {
        
        if currentDevice == backCamera {
            return frontCamera!
        }

        return backCamera!
    }
}

