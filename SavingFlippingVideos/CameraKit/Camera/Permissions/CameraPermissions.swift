//
//  CameraPermissionsInteractorImpl.swift
//  Vitcord
//
//  Created by Victor on 22/11/16.
//  Copyright © 2016 Vitcord. All rights reserved.
//

import Foundation
import AVFoundation

struct CameraPermissions {
    
    var canSaveVideo: Bool {
        return cameraAuthorizationStatus == .authorized && microAuthorizationStatus == .authorized
    }

    var cameraAuthorizationStatus: AVAuthorizationStatus {
        return AVAuthorizer.camera().authorizationStatus()
    }
    
    var microAuthorizationStatus: AVAuthorizationStatus {
        return AVAuthorizer.microphone().authorizationStatus()
    }
    
    func requestCameraPermissions(_ handler: @escaping (AVAuthorizationStatus) -> Void) {
        AVAuthorizer.camera().requestAuthorization(handler)
    }
    
    func requestMicroPermissions(_ handler: @escaping (AVAuthorizationStatus) -> Void) {
        AVAuthorizer.microphone().requestAuthorization(handler)
    }
}
