//
//  CameraViewController.swift
//  EasyCamera
//
//  Created by Carlos Roig on 19/1/18.
//  Copyright © 2018 CRS. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
//import GPUImage


class BaseCameraViewController: UIViewController {
    
    var presenter: CameraPresenter!
    var previewView: CameraPreviewView!

//    lazy var renderView: RenderView = {
//        return RenderView(frame: previewView.bounds)
//    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addPreviewGesturesRecognizers()
        presenter?.viewWillAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.viewWillDisappear()
        previewView.gestureRecognizers?.removeAll()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }
    
    fileprivate func addPreviewGesturesRecognizers() {
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapGesture(tap:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delegate = self
        previewView.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc fileprivate func doubleTapGesture(tap: UITapGestureRecognizer) {
        presenter?.switchCamera()
    }
    
}


extension BaseCameraViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    

}
