//
//  CameraPresenter.swift
//  EasyCamera
//
//  Created by Carlos Roig on 18/1/18.
//  Copyright © 2018 CRS. All rights reserved.
//


import Foundation
import AVFoundation
import UIKit
import GPUImage


class CameraPresenter: NSObject, CameraPresenterProtocol {
    
    weak var view: CameraPresenterView!
    
    fileprivate var beginZoomScale: CGFloat = 1.0
    fileprivate var zoomScale: CGFloat = 1.0
    fileprivate var previousPanTranslation: CGFloat = 0.0
    fileprivate var maxZoomScale = CGFloat.greatestFiniteMagnitude
    var navigator : CameraNavigator?
    fileprivate let cameraProgress: CameraProgress
    fileprivate let photoLibraryManager: PhotoLibraryManager
    fileprivate let cameraPermissions: CameraPermissions = CameraPermissions()
    fileprivate var fetchHashtags: FetchHashtags
    let queue = DispatchQueue(label: "com.vitcord.camera", attributes: [])
    
    var vitcord: Vitcord?
    var createWithMeUserId: String?
    var cameraController: CameraController!
    var hashtagViewModels: [HashtagViewModel]?
    
    
    var isJoiningStory: Bool {
        guard vitcord != nil else { return false }
        return true
    }
    
    lazy var viewModel: PermissionCameraViewModel = {
        var viewModel = PermissionCameraViewModel()
        viewModel.delegate = self
        return viewModel
    }()
    
    
    // MARK: - Private
    
    fileprivate func showCamera() {
        
        guard self.cameraPermissions.canSaveVideo else {
            self.viewModel.cameraPermissionState = self.cameraPermissions.canAccessCamera
            self.viewModel.micPermissionState = self.cameraPermissions.canAcccessMicro
            self.view.showPermissionsView(viewModel: self.viewModel)
            
            EventTracker.track(
                event:NewEvent(
                    EventType.pageView.rawValue,
                    ["microphone":self.viewModel.micPermissionState.toString(),
                     "camera": self.viewModel.cameraPermissionState.toString()],
                    section:"permissions_view"
                )
            )
            return
        }
        
        queue.async {
            if self.cameraController == nil {
                self.cameraController = BasicCameraController()
                self.resetCamera()
            }
            
            
            DispatchQueue.main.async {
                self.view.hidePermissionsView()
                self.view.preview(session: self.cameraController.session)
                self.cameraController.showCamera()
                self.updateTorchButtonState()
                self.view.setTorchButtonState(isTorchActive: self.cameraController.currentDevice.isTorchActive)
            }
        }
    }
    
    fileprivate func resetCamera() {
        guard cameraController != nil else { return }
        
        cameraController.cleanUp()
        
        if cameraController is BasicCameraController {
            cameraController = BasicCameraController(currentDevice: cameraController.currentDevice)
        }
        else {
            cameraController = FilterCameraController(renderView: view.renderView,
                                                      currentDevice: cameraController.currentDevice)
        }
        cameraController.setUp()
    }
    
    fileprivate func showPermissionsDeniedBanner() {
        NotificationCenter.default.post(
            name: Notification.Name.ShowBannerNotification,
            object: nil,
            userInfo: ["text" : "new_camera_permissions_denied_text".localize(),
                       "state" : BannerState.error.rawValue]
        )
    }
    
    fileprivate func finishedRecording(url: URL) {
        
        cameraController.cleanUp()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
            let duration = CMTimeGetSeconds(AVAsset(url: url).duration)
            self.clickRecordEnd(duration: duration)
            self.showPreviewViewController(url: url)
        })
    }
    
    fileprivate func showPreviewViewController(url: URL) {
        let previewVideoItem = PreviewVideoItem(videoURL: url, type: view.selectedType())
        
        if isJoiningStory {
            previewVideoItem.vitcord = vitcord
        } else {
            guard let hashtagPosition = view.selectedHashtagPosition(),
            let hashtagTitle = hashtagViewModels?[hashtagPosition].title else { return }
            let hashtag = Hashtag(name: hashtagTitle)
            hashtag.position = view.selectedHashtagPosition()
            previewVideoItem.hashtag = hashtag
        }
        navigator?.showPreview(previewVideoItem: previewVideoItem, createWithMeUserId: createWithMeUserId)
    }
    
    
    // MARK: - Camera
    
    func startRecording() {
        guard cameraPermissions.canSaveVideo else { return }
        
        view.startRecording()
        cameraController.startRecording { }
        cameraProgress.startTimer()
        clickRecordStart()
    }
    
    func stopRecording() {
        cameraProgress.stop()
        
        cameraController.stopRecording { [weak self] _ in
            self?.cameraController.finishRecording { [weak self] url in
                
                guard let url = url else {
                    DispatchQueue.main.async {
                        self?.view.showMinDuration()
                    }
                    return
                }
                DispatchQueue.main.async {
                    self?.view.stopRecording()
                }
                self?.finishedRecording(url: url)
            }
        }
    }
    
    func switchCamera() {
        if cameraController.isRecording {
            cameraProgress.pause()
        }
        
        cameraController.switchCamera { url in
            
            self.updateTorchButtonState()
            
            guard url != nil else {
                self.cameraProgress.stop()
                return
            }
            
            self.cameraProgress.start()
        }
    }
    
    func switchFilterCamera() {
        cameraController.cleanUp()
        
        if cameraController is BasicCameraController {
            cameraController = FilterCameraController(renderView: view.renderView,
                                                      currentDevice: cameraController.currentDevice)
        }
        else {
            cameraController = BasicCameraController(currentDevice: cameraController.currentDevice)
        }
        
        cameraController.setUp()
        showCamera()
    }
    
    
    // MARK: - Torch
    
    fileprivate func updateTorchButtonState() {
        if cameraController.currentDevice.isTorchAvailable {
            view.showTorch()
            return
        }
        view.hideTorch()
    }
    
    func torch() {
        let isTorchActive = cameraController.currentDevice.isTorchActive
        cameraController.toggleTorch()
        // Set with a negation because isTorchActive states is not updated instantly
        view.setTorchButtonState(isTorchActive: !isTorchActive)
    }
    
    
    // MARK: - Gestures
    
    func panGesture(translation: CGFloat, state: UIGestureRecognizerState) {
        
        let translationDifference = translation - previousPanTranslation
        let currentZoom = cameraController.currentDevice.videoZoomFactor
        zoomScale(with: currentZoom - (translationDifference / 75))
        if state == .ended || state == .failed || state == .cancelled {
            previousPanTranslation = 0.0
        } else {
            previousPanTranslation = translation
        }
    }
    
    func pinchZoom(_ scale: CGFloat) {
        zoomScale(with: scale * beginZoomScale)
    }
    
    func setBeginZoomScaleAsZoomScale() {
        beginZoomScale = zoomScale
    }
    
    fileprivate func zoomScale(with scale: CGFloat) {
        zoomScale = min(maxZoomScale,
                        max(1.0, min(scale, cameraController.currentDevice.activeFormat.videoMaxZoomFactor)))
        cameraController.setZoom(scale: zoomScale)
    }
    
    fileprivate func resetZoom() {
        guard zoomScale > 1.0 || beginZoomScale > 1.0 else { return }
        
        beginZoomScale = 1.0
        zoomScale = 1.0
        cameraController.setZoom(scale: zoomScale)
    }
    
    
    func focus(at tapPoint: CGPoint, on screenSize: CGSize) {
        let x = tapPoint.y / screenSize.height
        let y = 1.0 - tapPoint.x / screenSize.width
        cameraController.setFocus(at: CGPoint(x: x, y: y))
    }
    
    // MARK: - Navigation
    
    func showPreview(at url: URL) {
        let asset = AVAsset(url: url)
        guard CMTimeGetSeconds(asset.duration) > 2.0 else {
            view.showAlertTimeLessThanTwoSeconds()
            return
        }
        cameraRollSuccess()
        showPreviewViewController(url: url)
    }
    
    func closeCamera() {
        clickCloseCamera()
        navigator?.dismissCamera()
    }
    
    // MARK: - Initialization
    
    init(view: CameraPresenterView, cameraProgress: CameraProgress = CameraProgress(), photoLibraryManager: PhotoLibraryManager = PhotoLibraryManager(), fetchHashtags: FetchHashtags) {
        self.view = view
        self.cameraProgress = cameraProgress
        self.photoLibraryManager = photoLibraryManager
        self.fetchHashtags = fetchHashtags
        super.init()
        self.cameraProgress.delegate = self
    }
}


extension CameraPresenter: PresenterProtocol {
    
    func viewDidLoad() {
        PhotoLibraryAuthorizer().requestAuthorization { (status) in
            if status == .authorized {
                self.photoLibraryManager.getLastVideoThumbnail { (image) in
                    self.view.showGallery(image: image)
                }
            }
        }
        
        if let vitcord = vitcord {
            view.showJoinStory(thumbnailUrl: vitcord.vits.first?.thumbnailURL)
            pageView(.vitcordPlayer)
        }
        else if createWithMeUserId != nil {
            view.showJoinStory(thumbnailUrl: nil)
            pageView(.userProfile)
        }
        self.fetchHashtags.fetchHashtags(completion: { (viewModels) in
            guard let hashtagViewModels = viewModels else { return }
            self.hashtagViewModels = hashtagViewModels
            self.showHashtagsScroll()
        })
    }
    
    func viewWillAppear() {
        resetCamera()
        showCamera()
    }
    
    func viewWillDisappear() {
        if cameraController != nil {
            cameraController.cleanUp()
        }
    }
}

extension CameraPresenter: PermissionsCameraViewModelDelegate {
    
    func userDidAllowCameraAccess() {
        cameraPermissions.requestCameraPermissions { [weak self] (status) in
            self?.showCamera()
        }
    }
    
    func userDidAllowMicrophoneAccess() {
        cameraPermissions.requestMicroPermissions { [weak self] (status) in
            self?.showCamera()
        }
    }
    
    func userDidClose() {
        closeCamera()
    }
}


extension CameraPresenter: ListDataSource {
    
    func numberOfItems(in section: Int) -> Int {
        guard isJoiningStory else {
            return VitcordType.allCases.count
        }
        return 1
    }
    
    func cellViewModelForItem(at indexPath: IndexPath) -> CellViewModel {
        guard let vitcord = vitcord else {
            return VitcordType(rawValue: indexPath.item)!.vitcordTypeViewModel() as CellViewModel
        }
        var typeModel = VitcordTypeViewModel(title: vitcord.name)
        typeModel.isJoining = true
        return typeModel
    }
    
    func numberOfHashtags(in section: Int) -> Int {
        guard !isJoiningStory,
        let numberOfHashtags = hashtagViewModels?.count else {
            return 0
        }
        return numberOfHashtags
    }
    
    func cellViewModelForHashtag(at indexPath: IndexPath) -> CellViewModel {
        return hashtagViewModels![indexPath.item] as CellViewModel
    }
}


extension CameraPresenter: CameraProgressDelegate {
    
    func finishVideo() {
        stopRecording()
    }
    
    func set(_ progress: Double) {
        DispatchQueue.main.async {
        if progress >= 0.125 {
            self.view.hideMarkImage()
            self.view.changeProgressRing(color: .white)
        }
        self.view.setProgress(progress)
        }
    }
    
    func showHashtagsScroll() {
        self.view.showHashtagsScroll()
    }
}
