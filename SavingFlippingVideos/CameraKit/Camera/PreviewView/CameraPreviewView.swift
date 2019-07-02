//
//  CameraPreviewView.swift
//  EasyCamera
//
//  Created by Carlos Roig on 5/1/18.
//  Copyright © 2018 CRS. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPreviewView: UIView {
    
    open var session: AVCaptureSession? {
        get {
            return (layer as! AVCaptureVideoPreviewLayer).session ?? nil
        }
        set (session) {
            (layer as? AVCaptureVideoPreviewLayer)?.session = session
            (layer as? AVCaptureVideoPreviewLayer)?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        }
    }
    
    override class open var layerClass : AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
