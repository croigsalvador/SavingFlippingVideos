//
//  CameraPresenter.swift
//  EasyCamera
//
//  Created by Carlos Roig on 18/1/18.
//  Copyright © 2018 CRS. All rights reserved.
//


import Foundation
import AVFoundation
import UIKit

class CameraPresenter: NSObject, CameraPresenterProtocol {
    
    weak var view: CameraPresenterView!
    fileprivate let cameraPermissions: CameraPermissions = CameraPermissions()
    let queue = DispatchQueue(label: "com.vitcord.camera", attributes: [])
    var cameraController: CameraController!

    
    // MARK: - Private
    
    fileprivate func showCamera() {
        
        guard self.cameraPermissions.canSaveVideo else {
            cameraPermissions.requestCameraPermissions { [weak self] (status) in
                self?.cameraPermissions.requestMicroPermissions { [weak self] (status) in
                self?.showCamera()
                }
            }
            return
                
        }
        
        queue.async {
            if self.cameraController == nil {
                self.cameraController = BasicCameraController()
                self.resetCamera()
            }
            
            
            DispatchQueue.main.async {
                self.view.preview(session: self.cameraController.session)
                self.cameraController.showCamera()
            }
        }
    }
    
    fileprivate func resetCamera() {
        guard cameraController != nil else { return }
        
        cameraController.cleanUp()
        cameraController = BasicCameraController(currentDevice: cameraController.currentDevice)
        
//        if cameraController is BasicCameraController {
        
//        }
//        else {
//            cameraController = FilterCameraController(renderView: view.renderView,
//                                                      currentDevice: cameraController.currentDevice)
//        }
        cameraController.setUp()
    }

    
    fileprivate func finishedRecording(url: URL) {
        
        cameraController.cleanUp()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
            let duration = CMTimeGetSeconds(AVAsset(url: url).duration)
            self.showPreviewViewController(url: url)
        })
    }
    
    fileprivate func showPreviewViewController(url: URL) {
        
    }
    
    
    // MARK: - Camera
    
    func startRecording() {
        guard cameraPermissions.canSaveVideo else { return }
        
        cameraController.startRecording { }
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
    }
    
    func switchCamera() {
        cameraController.switchCamera { url in}
    }
    
//    func switchFilterCamera() {
//        cameraController.cleanUp()
//
//        if cameraController is BasicCameraController {
//            cameraController = FilterCameraController(renderView: view.renderView, currentDevice: cameraController.currentDevice)
//        }
//        else {
//            cameraController = BasicCameraController(currentDevice: cameraController.currentDevice)
//        }
//
//        cameraController.setUp()
//        showCamera()
//    }

    
    // MARK: - Navigation
    
    func showPreview(at url: URL) {
        showPreviewViewController(url: url)
    }
    
    func closeCamera() {
    
    }
    
    // MARK: - Initialization
    
    init(view: CameraPresenterView) {
        self.view = view
    }
}


extension CameraPresenter: PresenterProtocol {
    
    func viewWillAppear() {
        resetCamera()
        showCamera()
    }
    
    func viewWillDisappear() {
        if cameraController != nil {
            cameraController.cleanUp()
        }
    }
}

