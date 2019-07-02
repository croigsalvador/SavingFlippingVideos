//
//  AVCaptureSession.swift
//  EasyCamera
//
//  Created by Carlos Roig on 18/1/18.
//  Copyright © 2018 CRS. All rights reserved.
//

import Foundation
import AVFoundation

extension AVCaptureSession {
    static func configure(_ session: AVCaptureSession = AVCaptureSession(), with settings: CameraSettings) -> AVCaptureSession? {
        guard let session = session.configureSession(session, settings) else {
            return nil
        }
        if !session.isRunning {
            session.startRunning()
        }
        return session
    }
    
    func update(_ settings:CameraSettings) -> AVCaptureSession? {
        return configureSession(self, settings)
    }
    
    @discardableResult
    func configureSession(_ session:AVCaptureSession,_ settings: CameraSettings) -> AVCaptureSession? {
        session.beginConfiguration()
        if session.canSetSessionPreset(AVCaptureSession.Preset.high){
            session.sessionPreset = AVCaptureSession.Preset.high
        }
        
        session.inputs.forEach {  session.removeInput($0) }
        
        guard let videoInput = settings.videoInput,
            session.canAddInput(videoInput) else {
                return nil
        }
        session.addInput(videoInput)
        
        guard let microInput = settings.audioInput, session.canAddInput(microInput) else {
            return nil
        }
        session.addInput(microInput)
        
        session.commitConfiguration()
        return session
    }
}
