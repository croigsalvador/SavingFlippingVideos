//
//  Devices.swift
//  Vitcord
//
//  Created by Víctor on 17/2/16.
//  Copyright © 2016 Vitcord. All rights reserved.
//

import Foundation

/// Represents an input device with ussage restrictions are defined by user
/// and should be asked on first ussage
public protocol Authorizer {
  /// Checks current authorization status
  ///
  /// - Returns: Current authorization status
    @discardableResult
  func authorizationStatus() -> AuthorizationStatus

  /// Requests permissions to the user
  ///
  /// - Parameters: Closure where receive the status
  func requestAuthorization(_ fromHandler: @escaping (AuthorizationStatus) -> Void)
}

public extension Authorizer {
   static func string(for status: AuthorizationStatus) -> String {
        switch status {
        case .denied:
            return "denied"
        case .notDetermined:
            return "not determined"
        case .authorized:
            return  "authorized"
        }
    }
}
