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

    
    func setMirroring(in videoOutput: AVCaptureVideoDataOutput)
    func setUpFrontCameraMirroring(in connection: AVCaptureConnection)
    func setUpBackCameraMirroring(in connection: AVCaptureConnection)
    
    func videoSaved(in url: URL)
    func finishRecording(completion: @escaping (URL?) -> Void)
}


extension CameraController {

    
    
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
    
    func setUpFrontCameraMirroring(in connection: AVCaptureConnection) {}
    
    func setUpBackCameraMirroring(in connection: AVCaptureConnection) {}
    
    
    func videoSaved(in url: URL) {
        videoUrls.append(url)
    }
    
    func finishRecording(completion: @escaping (URL?) -> Void) {
        
        guard !videoUrls.isEmpty else {
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
