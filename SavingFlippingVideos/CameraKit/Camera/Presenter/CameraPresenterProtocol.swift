//
//  CameraViewController.swift
//  EasyCamera
//
//  Created by Carlos Roig on 19/1/18.
//  Copyright © 2018 CRS. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
//import GPUImage

protocol CameraPresenterProtocol: PresenterProtocol {

    var view: CameraPresenterView! { get }
    func startRecording()
    func stopRecording()
    func switchCamera()
    func closeCamera()
}

protocol CameraPresenterView: class {

    var presenter: CameraPresenter! { get set }
//    var renderView: RenderView { get }
    func preview(session: AVCaptureSession?)
}
