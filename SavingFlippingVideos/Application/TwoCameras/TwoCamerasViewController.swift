//
//  TwoCamerasViewController.swift
//  SavingFlippingVideos
//
//  Created by Carlos Roig on 03/07/2019.
//  Copyright © 2019 Vitcord. All rights reserved.
//

import UIKit
import AVKit

class TwoCamerasViewController: UIViewController {
    
    var presenter: TwoCamerasPresenter!
    
    var topPreviewView: CameraPreviewView!
    var bottomPreviewView: CameraPreviewView!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var topPreviewContainer: UIView!
    @IBOutlet weak var bottomPreviewContainer: UIView!
    
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
        presenter = TwoCamerasPresenter(view: self)
        
        topPreviewView = CameraPreviewView(frame: topPreviewContainer.bounds)
        topPreviewContainer.insertSubview(topPreviewView, at: 0)
        
        bottomPreviewView = CameraPreviewView(frame: bottomPreviewContainer.bounds)
        bottomPreviewContainer.insertSubview(bottomPreviewView, at: 0)
        
        presenter.viewDidLoad()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        navigationController?.navigationBar.isHidden = true
        topPreviewView.frame = topPreviewContainer.bounds
        bottomPreviewView.frame = bottomPreviewContainer.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.viewWillDisappear()
    }

}

extension TwoCamerasViewController: TwoCamerasPresenterView {

    func preview(session: AVCaptureSession?) {
        topPreviewView.session = session
    }
    
    func bottomPreview(session: AVCaptureSession?) {
        bottomPreviewView.session = session
    }
    
    func showVideo(url: URL) {
        
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(playerViewController, animated: true)
    }
}
