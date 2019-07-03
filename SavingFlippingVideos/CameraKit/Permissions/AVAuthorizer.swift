//
//  CameraDevice.swift
//  Vitcord
//
//  Created by Víctor on 17/2/16.
//  Copyright © 2016 Vitcord. All rights reserved.
//

import Foundation
import AVFoundation

struct AVAuthorizer {

  fileprivate let device: String
  
  fileprivate init(device: String) {
    self.device = device
  }

  internal static func createHandler(_ device: String, handler: @escaping (AVAuthorizationStatus) -> Void)
    -> ((Bool) -> Void) {
      return { granted in
        var status = AVAuthorizationStatus.notDetermined
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
  func authorizationStatus() -> AVAuthorizationStatus {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType(rawValue: device))
    return status
  }

  func requestAuthorization(_ fromHandler: @escaping (AVAuthorizationStatus)
    -> Void) {
    let requestHandler = AVAuthorizer.createHandler(device, handler: fromHandler)
    AVCaptureDevice.requestAccess(for: AVMediaType(rawValue: device),
        completionHandler:requestHandler)
  }

  // MARK: Factory

  /// Returns camera authorizer
  internal static func camera() -> AVAuthorizer {
    return AVAuthorizer(device: AVMediaType.video.rawValue)
  }

  /// Returns microphone authorizer
  internal static func microphone() -> AVAuthorizer {
    return AVAuthorizer(device: AVMediaType.audio.rawValue)
  }
}

