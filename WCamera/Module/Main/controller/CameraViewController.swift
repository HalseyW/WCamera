//
//  CameraViewController.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/8.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import UIKit
import MediaPlayer

class CameraViewController: UIViewController {
    override var prefersStatusBarHidden: Bool { return !DeviceUtils.isNotchDevice() }
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var btnFlashMode: UIButton!
    @IBOutlet weak var btnSwitchDualCamera: UIButton!
    @IBOutlet weak var btnSwitchFrontAndBackCamera: UIButton!
    @IBOutlet weak var btnCapturePhoto: UIButton!
    @IBOutlet weak var btnAutoMode: UIButton!
    @IBOutlet weak var ivFocus: UIImageView!
    
    var uiManualOpt: UIView?
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
    var uiSliderManualOpt: UIView?
    var btnManualOptAuto: UIButton?
    var sliderManualOpt: UISlider?
    
    let cameraManager = CameraManager.shared
    var isPermissionAuthorized = true
    var focusImageViewTapAnimator: UIViewPropertyAnimator?
    lazy var tapticEngineGenerator = UIImpactFeedbackGenerator.init(style: .light)
    lazy var currentVolume: Float = -1
    lazy var canCaptureWhenPressVolumeButton = true
    lazy var flashModeButtonImages = [UIImage.init(named: "flash_off"), UIImage.init(named: "flash_on"), UIImage.init(named: "flash_auto")]
    var isCameraSwitchComplete: Bool? {
        willSet {
            guard let value = newValue else { return }
            self.btnCapturePhoto?.isEnabled = value
            self.btnSwitchFrontAndBackCamera?.isEnabled = value
            self.btnSwitchDualCamera?.isEnabled = value
        }
    }
    
    override func loadView() {
        super.loadView()
        initView()
    }

    override func viewDidLoad() {
        //判断权限并构建CameraManager
        Permission.buildPermission(type: .Camera, message: "需要您的授权才能使用照相机进行拍照").request { (status) in
            if status == .authorized {
                self.cameraManager.buildSession(delegate: self)
            }
        }
        //按下实体音量键监听
        NotificationCenter.default.addObserver(self, selector: #selector(onPressVolumeButton(notification:)), name: NSNotification.Name.init("AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        //App运行状态监听
        NotificationCenter.default.addObserver(self, selector: #selector(willBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive(notification:)), name: UIApplication.willResignActiveNotification, object: nil)
        super.viewDidLoad()
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
