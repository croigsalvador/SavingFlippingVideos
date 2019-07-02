//
//  BasicCameraController.swift
//  Vitcord
//
//  Created by Juan Garcia on 17/10/18.
//  Copyright © 2018 Vitcord. All rights reserved.
//

import AVFoundation


final class BasicCameraController: NSObject, CameraController {

    var currentDevice: AVCaptureDevice!
    var isRecording = false
    var canSwitchCameraWhileRecording = true
    var videoComposition: VideoComposition = VideoComposition()
    var videoUrls: [URL] = []
    
    fileprivate var cameraSettings: CameraSettings
    fileprivate var filePathUrl: URL!
    
    fileprivate var videoDataOutput: AVCaptureVideoDataOutput!
    fileprivate var audioDataOutput: AVCaptureAudioDataOutput!
    fileprivate var videoWriter: VideoWriter!
    fileprivate let lockQueue = DispatchQueue(label: "com.vitcord.BasicCameraController.LockQueue")
    fileprivate let recordingQueue = DispatchQueue(label: "com.vitcord.BasicCameraController.RecordingQueue")
    fileprivate var currentBuffer: CMSampleBuffer?
    fileprivate var captureSession: AVCaptureSession?
    
    var session: AVCaptureSession? {
        return captureSession
    }
    
    
    func setUp() {
        
        /**
         TODO: clean cameraSettings
         **/
        
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: recordingQueue)
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String : Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
        ]
        
        audioDataOutput = AVCaptureAudioDataOutput()
        audioDataOutput.setSampleBufferDelegate(self, queue: recordingQueue)

        captureSession?.addOutput(videoDataOutput)
        captureSession?.addOutput(audioDataOutput)
        setMirroring()
    }
    
    func cleanUp() {
        guard let session = session else { return }
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    
    // MARK: - Camera
    
    func showCamera() {

    }
    
    func startRecording(completion: (() -> Void)?) {
        
        let settings = VideoOutputSettings.vitcordVideoOutputSettings()
        let outputSize = settings.outputSize
        filePathUrl = URL.createFileURL()
        
        self.videoWriter = VideoWriter(
            fileUrl: filePathUrl!,
            height: outputSize.height,
            width: outputSize.width
        )

        lockQueue.sync {
            isRecording = true
        }

        completion?()
    }
    
    func stopRecording(completion: ((URL?) -> Void)?) {
        
        guard isRecording else {
            completion?(nil)
            return
        }

        isRecording = false

        lockQueue.sync {
            self.videoWriter.finish { duration in
                
                let url = self.filePathUrl!
                let isVideoValid = self.saveVideo(in: url, duration: duration)
                
                guard isVideoValid else {
                    completion?(nil)
                    return
                }
                completion?(url)
            }
        }
    }
    
    func switchCamera(completion: ((URL?) -> Void)?) {
        
        stopRecording { url in
            
            self.switchDeviceCamera()
            guard let url = url else {
                completion?(nil)
                return
            }
            
            self.startRecording {
                completion?(url)
            }
        }
    }

    func setUpFrontCameraMirroring(in connection: AVCaptureConnection) {
        connection.videoOrientation = .landscapeRight
    }
    
    
    // MARK: - Private
    
    fileprivate func switchDeviceCamera() {
        
        /**
         TODO: lo de camera settings y device arreglarlo que tela...
         **/
        currentDevice = cameraSettings.switchCamera(currentDevice: currentDevice)
        cameraSettings = cameraSettings.setCamera(currentDevice)
        captureSession = captureSession?.update(cameraSettings)
        setMirroring()
    }
    
    fileprivate func setMirroring() {
        setMirroring(in: videoDataOutput)
    }
    
    
    // MARK: - Initialization
    
    init(currentDevice: AVCaptureDevice? = nil) {
        self.cameraSettings = currentDevice != nil ? DefaultCameraSettings(currentDevice) : DefaultCameraSettings()
        self.currentDevice = self.cameraSettings.camera!
        self.captureSession = AVCaptureSession.configure(with: cameraSettings)
    }
}

extension BasicCameraController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        let isVideo = output is AVCaptureVideoDataOutput
        
        if isVideo {
            currentBuffer = sampleBuffer
        }
        
        guard isRecording else { return }

        lockQueue.sync {
            self.videoWriter.write(sampleBuffer, isVideo: isVideo)
        }
    }
}
