//
//  CameraDevice.swift
//  Vitcord
//
//  Created by Víctor on 17/2/16.
//  Copyright © 2016 Vitcord. All rights reserved.
//

import Foundation
import AVFoundation

struct AVAuthorizer: Authorizer {

  fileprivate let device: String
  
  fileprivate init(device: String) {
    self.device = device
  }

  internal static func createHandler(_ device: String, handler: @escaping (AuthorizationStatus) -> Void)
    -> ((Bool) -> Void) {
      return { granted in
        var status = AuthorizationStatus.notDetermined
        switch granted {
        case true:
          status = .authorized
        case false:
          status = .denied
        }
        
        DispatchQueue.main.async {
          handler(status)
        }
      }
  }

  // MARK: Authorizer
    @discardableResult
  func authorizationStatus() -> AuthorizationStatus {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType(rawValue: device))
            .map()
    return status
  }

  func requestAuthorization(_ fromHandler: @escaping (AuthorizationStatus)
    -> Void) {
    let type = device as String == AVMediaType.video.rawValue ? "camera" : "microphone"
    EventTracker.track(event: NewEvent.init("permission_show", ["type":type], section: ""))
    let requestHandler = AVAuthorizer.createHandler(device, handler: fromHandler)
    AVCaptureDevice.requestAccess(for: AVMediaType(rawValue: device),
        completionHandler:requestHandler)
  }

  // MARK: Factory

  /// Returns camera authorizer
  internal static func camera() -> Authorizer {
    return AVAuthorizer(device: AVMediaType.video.rawValue)
  }

  /// Returns microphone authorizer
  internal static func microphone() -> Authorizer {
    return AVAuthorizer(device: AVMediaType.audio.rawValue)
  }
}

