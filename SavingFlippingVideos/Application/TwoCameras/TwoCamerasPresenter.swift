//
//  TwoCamerasPresenter.swift
//  SavingFlippingVideos
//
//  Created by Carlos Roig on 03/07/2019.
//  Copyright © 2019 Vitcord. All rights reserved.
//

import Foundation
import AVFoundation

protocol TwoCamerasPresenterView: class {
    
    func preview(session: AVCaptureSession?)
    func bottomPreview(session: AVCaptureSession?)
    
    func showVideo(url: URL)
}

final class TwoCamerasPresenter {
    
    fileprivate let queue = DispatchQueue(label: "com.vitcord.camera", attributes: [])
    fileprivate let bottomQueue = DispatchQueue(label: "com.vitcord.frontCamera", attributes: [])
    
    fileprivate var cameraController: CameraController!
    fileprivate var bottomCameraController: CameraController!
    fileprivate weak var view: TwoCamerasPresenterView!
    
    // MARK: - Private
    
    fileprivate func showCamera() {
        
        queue.async {
            if self.cameraController == nil {
                self.cameraController = BasicCameraController(currentDevice: AVCaptureDevice.camera(.back))
                self.resetCamera()
            }
            
            DispatchQueue.main.async {
                self.view.preview(session: self.cameraController.session)
                self.cameraController.showCamera()
            }
        }
        
        bottomQueue.async {
            
            
            if self.bottomCameraController == nil {
                self.bottomCameraController = BasicCameraController(currentDevice: AVCaptureDevice.camera(.front))
                self.resetBottomCamera()
            }
            
            DispatchQueue.main.async {
                self.view.bottomPreview(session: self.bottomCameraController.session)
                self.bottomCameraController.showCamera()
            }
        }
    }
    
    fileprivate func resetCamera() {
        if cameraController != nil {
            cameraController.cleanUp()
            cameraController = BasicCameraController(currentDevice: cameraController.currentDevice)
            
            cameraController.setUp()
            
        }
    }
    
    fileprivate func resetBottomCamera() {
        if bottomCameraController != nil {
            bottomCameraController.cleanUp()
            bottomCameraController = BasicCameraController(currentDevice: bottomCameraController.currentDevice)
            
            bottomCameraController.setUp()
        }
    }
    
    fileprivate func finishedRecording(url: URL) {
        cameraController.cleanUp()
        bottomCameraController.cleanUp()
        
        DispatchQueue.main.async {
            self.view.showVideo(url: url)
        }
    }
    
    // MARK: - Camera
    
    func startRecording() {
        cameraController.startRecording { }
        bottomCameraController.startRecording { }
    }
    
    func stopRecording() {
        
        cameraController.stopRecording { [weak self] _ in
            self?.cameraController.finishRecording { [weak self] url in
                
                guard let url = url else {
                    return
                }
                self?.finishedRecording(url: url)
            }
        }
        
        bottomCameraController.stopRecording { [weak self] _ in
            self?.bottomCameraController.finishRecording { [weak self] url in
                
                guard let url = url else {
                    return
                }
                self?.finishedRecording(url: url)
            }
        }
    }
    
    // MARK: - Initialization
    
    init(view: TwoCamerasPresenterView) {
        self.view = view
    }
}


extension TwoCamerasPresenter: PresenterProtocol {
    
    func viewWillAppear() {
        resetCamera()
        showCamera()
    }
    
    func viewWillDisappear() {
        if cameraController != nil {
            cameraController.cleanUp()
        }
        
        if bottomCameraController != nil {
            bottomCameraController.cleanUp()
        }
    }
}
