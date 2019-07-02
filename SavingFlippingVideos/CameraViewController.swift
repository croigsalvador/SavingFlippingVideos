//
//  CameraViewController.swift
//  Vitcord
//
//  Created by Juan Garcia on 22/10/18.
//  Copyright © 2018 Vitcord. All rights reserved.
//

import UIKit
import AVFoundation

final class CameraViewController: BaseCameraViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var previewContainer: UIView!
    @IBOutlet weak var topButtonsContainer: UIView!
    
    @IBOutlet weak var topContainerConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomContainerConstraint: NSLayoutConstraint!
    
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        presenter.closeCamera()
    }
    
    @IBAction func recordButtonTouchDown(_ sender: UIButton) {
        presenter?.startRecording()
    }
    
    @IBAction func recordButtonTouchUp(_ sender: UIButton) {
        presenter?.stopRecording()
    }
    
    @IBAction func recordButtonTouchUpOutside(_ sender: UIButton) {
        presenter?.stopRecording()
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        previewView = CameraPreviewView(frame: previewContainer.bounds)
        previewContainer.insertSubview(previewView, at: 0)
        
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        previewView.frame = previewContainer.bounds
//        renderView.frame = previewContainer.bounds
    }
}


extension CameraViewController: CameraPresenterView {
    
    func preview(session: AVCaptureSession?) {
        previewView.session = session
        
        if session != nil {
//            renderView.removeFromSuperview()
            previewContainer.insertSubview(previewView, at: 0)
            
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //                UIView.animate(withDuration: 0.2) {
            //                    self.blurView.alpha = 0.0
            //                }
            //            }
        }
        else {
            previewView.removeFromSuperview()
//            previewContainer.insertSubview(renderView, at: 0)
        }
    }
}

