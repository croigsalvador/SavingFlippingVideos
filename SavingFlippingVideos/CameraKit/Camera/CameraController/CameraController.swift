//
//  CameraController.swift
//  Vitcord
//
//  Created by Juan Garcia on 16/10/18.
//  Copyright © 2018 Vitcord. All rights reserved.
//

import AVFoundation


protocol CameraController: class {

    var currentDevice: AVCaptureDevice! { get }
    var session: AVCaptureSession? { get }
    var isRecording: Bool { get }
    var canSwitchCameraWhileRecording: Bool { get }
    var videoComposition: VideoComposition { get }
    var videoUrls: [URL] { get set }
    
    func setUp()
    func cleanUp()
    
    func showCamera()
    func switchCamera(completion: ((URL?) -> Void)?)
    func startRecording(completion: (() -> Void)?)
    func stopRecording(completion: ((URL?) -> Void)?)
    
    func setFocus(at point: CGPoint)
    func setZoom(scale: CGFloat)
    func toggleTorch()
    
    func setMirroring(in videoOutput: AVCaptureVideoDataOutput)
    func setUpFrontCameraMirroring(in connection: AVCaptureConnection)
    func setUpBackCameraMirroring(in connection: AVCaptureConnection)
    
    func saveVideo(in url: URL, duration: TimeInterval) -> Bool
    func videoSaved(in url: URL)
    func finishRecording(completion: @escaping (URL?) -> Void)
}


extension CameraController {
    
    func setZoom(scale: CGFloat) {
        currentDevice.configureZoom(with: scale)
    }
    
    func setFocus(at point: CGPoint) {
        currentDevice.configureFocus(at: point)
    }
    
    func toggleTorch() {
        guard currentDevice.isTorchAvailable else { return }
        currentDevice.torch(on: !currentDevice.isTorchActive)
    }
    
    
    // MARK: - Mirroring
    
    func setMirroring(in videoOutput: AVCaptureVideoDataOutput) {
        
        guard
            let videoConnection = videoOutput.connection(with: .video),
            videoConnection.isVideoMirroringSupported
        else {
            return
        }
        
        if currentDevice.position == .front {
            videoConnection.isVideoMirrored = true
            setUpFrontCameraMirroring(in: videoConnection)
        }
        else {
            videoConnection.isVideoMirrored = false
            setUpBackCameraMirroring(in: videoConnection)
        }
    }
    
    func setUpFrontCameraMirroring(in connection: AVCaptureConnection) {
        
    }
    
    func setUpBackCameraMirroring(in connection: AVCaptureConnection) {
        
    }
    
    
    // MARK: - File video saving
    
    func saveVideo(in url: URL, duration: TimeInterval) -> Bool {
        print("🧐 Video duration \(duration)")
        guard false == (duration < 2.0 && videoUrls.isEmpty), duration <= 15.05 else {
            return false
        }
        
        videoSaved(in: url)
        return true
    }
    
    func videoSaved(in url: URL) {
        videoUrls.append(url)
    }
    
    func finishRecording(completion: @escaping (URL?) -> Void) {
        
        guard videoUrls.isNotEmpty else {
            completion(nil)
            return
        }
        
        guard videoUrls.count > 1 else {
            completion(videoUrls.first)
            videoUrls = [URL]()
            cleanUp()
            return
        }
        
        videoComposition.videoMix(of: videoUrls, in: URL.createFileURL(), with: { result in
            
            self.videoUrls = [URL]()

            switch result {
                
            case .success(let url):
                completion(url)
                guard url != nil else { return }
                self.cleanUp()
                
            case .failure(_):
                completion(nil)
            }
        })
    }
}
