//
//  CameraPermissionsInteractorImpl.swift
//  Vitcord
//
//  Created by Victor on 22/11/16.
//  Copyright © 2016 Vitcord. All rights reserved.
//

import Foundation
import CoreLocation

struct CameraPermissions {
    let permissions: Permissions
    let locationAuthorizer: CLAuthorizer
    
    init(_ permissions: Permissions = Permissions()) {
        self.permissions        = permissions
    }
}

extension CameraPermissions {
    
    var canSaveVideo: Bool {
        return canAccessCamera == .authorized && canAcccessMicro == .authorized
    }

    var canAccessCamera: AuthorizationStatus {
        return AVAuthorizer.camera().authorizationStatus()
    }
    
    var canAcccessMicro: AuthorizationStatus {
        return AVAuthorizer.microphone().authorizationStatus()
    }
    
    func requestCameraPermissions(_ handler: @escaping (AuthorizationStatus) -> Void) {
        AVAuthorizer.camera().requestAuthorization(handler)
    }
    
    func requestMicroPermissions(_ handler: @escaping (AuthorizationStatus) -> Void) {
        AVAuthorizer.microphone().requestAuthorization(handler)
    }
}
