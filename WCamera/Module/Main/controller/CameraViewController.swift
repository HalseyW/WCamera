//
//  CameraViewController.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/8.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController {
    override var prefersStatusBarHidden: Bool { return true }
    var previewView: PreviewView?
    var btnCapturePhoto: UIButton?
    var sliderISO: UISlider?
    let cameraManager = CameraManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        cameraManager.buildSession(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cameraManager.startRunning()
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        cameraManager.stopRunning()
        super.viewWillDisappear(animated)
    }
    
    @objc func onClickCapturePhotoButton() {
        cameraManager.capturePhoto()
    }
    
    @objc func isoSliderValueDidChange(sender: UISlider) {
        let iso = sender.value
//        cameraManager.changeISO(to: iso)
//        cameraManager.changeEV(to: iso)
        cameraManager.changeExposureDuration(to: Double(iso))
    }
}

extension  CameraViewController: CameraManagerDelegate {
    func getPreviewView() -> PreviewView {
        return previewView!
    }
    
    func getCapturePhotoButton() -> UIButton {
        return btnCapturePhoto!
    }
}
