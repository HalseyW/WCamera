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
import MediaPlayer

class CameraViewController: UIViewController {
    override var prefersStatusBarHidden: Bool { return !DeviceUtils.isNotchDevice() }
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    let previewView = PreviewView.init()
    var btnFlashMode: UIButton?
    var btnSwitchDualCamera: UIButton?
    var btnSwitchFrontAndBackCamera: UIButton?
    var btnCapturePhoto: UIButton?
    var btnAutoMode: UIButton?
    var ivFocus: UIImageView?
    var tvEvTitle: UILabel?
    var tvEv: UILabel?
    var evBottomLine: UIView?
    var tvEtTitle: UILabel?
    var tvEt: UILabel?
    var etBottomLine: UIView?
    var tvIsoTitle: UILabel?
    var tvIso: UILabel?
    var isoBottomLine: UIView?
    var tvFocusTitle: UILabel?
    var tvFocus: UILabel?
    var focusBottomLine: UIView?
    var mpVolumeView: MPVolumeView?
    let cameraManager = CameraManager.shared
    var focusImageViewTapAnimator: UIViewPropertyAnimator?
    lazy var tapticEngineGenerator = UIImpactFeedbackGenerator.init(style: .light)
    lazy var currentVolume: Float = -1
    lazy var canCaptureWhenPressVolumeButton = true
    lazy var flashModeButtonImages = [UIImage.init(named: "flash_off"), UIImage.init(named: "flash_on"), UIImage.init(named: "flash_auto")]
    
    override func loadView() {
        super.loadView()
        initView()
        cameraManager.buildSession(delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //按下实体音量键监听
        NotificationCenter.default.addObserver(self, selector: #selector(onPressVolumeButton(notification:)), name: NSNotification.Name.init("AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        //App运行状态监听
        NotificationCenter.default.addObserver(self, selector: #selector(willBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive(notification:)), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func willBecomeActive(notification: Notification) {
        cameraManager.startRunning()
        currentVolume = getCurrentVolume()
        canCaptureWhenPressVolumeButton = true
    }
    
    @objc func willResignActive(notification: Notification) {
        cameraManager.stopRunning()
        canCaptureWhenPressVolumeButton = false
        getMPVolumeSlider().value = currentVolume
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
}
