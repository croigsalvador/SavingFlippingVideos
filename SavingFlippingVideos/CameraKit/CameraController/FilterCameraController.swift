////
////  FilterCameraController.swift
////  Vitcord
////
////  Created by Juan Garcia on 16/10/18.
////  Copyright © 2018 Vitcord. All rights reserved.
////
//
//import Foundation
//import AVFoundation
//import GPUImage
//
//
//final class FilterCameraController: CameraController {
//    
//    var currentDevice: AVCaptureDevice!
//    var isRecording = false
//    var canSwitchCameraWhileRecording = false
//    var videoComposition: VideoComposition = VideoComposition()
//    var videoUrls: [URL] = []
//
//    fileprivate var cameraSettings: CameraSettings
//    fileprivate var filePathUrl: URL!
//    fileprivate var camera: Camera!
//    fileprivate var currentFilter: ImageProcessingOperation!
//    fileprivate var renderView: RenderView
//    fileprivate var videoWriter: MovieOutput!
//    
//    var session: AVCaptureSession? {
//        return nil
//    }
//    
//    func setUp() {
//        currentFilter = pixellateFilter()
//    }
//    
//    func cleanUp() {
//        camera.removeAllTargets()
//        camera.audioEncodingTarget = nil
//        currentFilter.removeAllTargets()
//    }
//    
//    
//    // MARK: - Camera
//    
//    func showCamera() {
//        
//        guard false == camera.captureSession.isRunning else { return }
//        camera.addTarget(currentFilter)
//        currentFilter --> renderView
//        setMirroring()
//        camera.startCapture()
//    }
//    
//    func startRecording(completion: (() -> Void)?) {
//        
//        isRecording = true
//        let settings = VideoOutputSettings.vitcordVideoOutputSettings()
//        let outputSize = settings.outputSize
//        self.filePathUrl = URL.createFileURL()
//        
//        videoWriter = try! MovieOutput(URL: filePathUrl,
//                                        size: outputSize.gpuImageSize,
//                                        fileType: .mp4,
//                                        liveVideo: true,
//                                        settings: settings.settings)
//        
//        camera.audioEncodingTarget = videoWriter
//        currentFilter --> videoWriter
//        videoWriter.startRecording()
//        completion?()
//    }
//    
//    func stopRecording(completion: ((URL?) -> Void)?) {
//        
//        isRecording = false
//        camera.stopCapture()
//        videoWriter.finishRecording {
//            
//            let url = self.filePathUrl!
//            let duration = CMTimeGetSeconds(AVAsset(url: url).duration)
//            
//            let isVideoValid = self.saveVideo(in: url, duration: duration)
//            guard isVideoValid else {
//                self.resetCamera()
//                completion?(nil)
//                return
//            }
//            
//            completion?(url)
//        }
//    }
//    
//    func switchCamera(completion: ((URL?) -> Void)?) {
//        
//        guard isRecording == false else { return }
//
//        camera.stopCapture()
//        currentDevice = cameraSettings.switchCamera(currentDevice: currentDevice)
//        resetCamera()
//    }
//    
//    
//    
//    // MARK: - Private
//    
//    fileprivate func pixellateFilter() -> Pixellate {
//        let filter = Pixellate()
//        filter.fractionalWidthOfAPixel = 0.038
//        return filter
//    }
//    
//    fileprivate func setMirroring() {
//        setMirroring(in: camera.videoOutput)
//    }
//    
//    fileprivate func resetCamera() {
//        cleanUp()
//        camera = try? Camera(sessionPreset: .hd1280x720,
//                             cameraDevice: currentDevice)
//        showCamera()
//    }
//    
//    
//    // MARK: - Initialization
//    
//    init(renderView: RenderView, currentDevice: AVCaptureDevice? = nil) {
//        
//        self.renderView = renderView
//        self.cameraSettings = currentDevice != nil ? DefaultCameraSettings(currentDevice) : DefaultCameraSettings()
//        self.currentDevice = self.cameraSettings.camera!
//        self.camera = try? Camera(sessionPreset: .hd1280x720,
//                                  cameraDevice: self.currentDevice)
//    }
//}
