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
    var mpVolumeView: MPVolumeView?
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var btnFlashMode: UIButton!
    @IBOutlet weak var btnSwitchDualCamera: UIButton!
    @IBOutlet weak var btnSwitchFrontAndBackCamera: UIButton!
    @IBOutlet weak var btnCapturePhoto: UIButton!
    @IBOutlet weak var btnAutoMode: UIButton!
    @IBOutlet weak var ivFocus: UIImageView!
    @IBOutlet weak var sliderManualOpt: UISlider!
    @IBOutlet weak var uiManualOpt: UIView!
    @IBOutlet weak var tvSliderMinValue: UILabel!
    @IBOutlet weak var tvSliderMaxValue: UILabel!
    @IBOutlet weak var tvEvCurrentValue: UILabel!
    @IBOutlet weak var tvEtCurrentValue: UILabel!
    @IBOutlet weak var tvISOCurrentValue: UILabel!
    @IBOutlet weak var tvFlCurrentValue: UILabel!
    
    lazy var sliderMode = -1
    var currentEvValue: Float = 0 {
        willSet {
            if newValue < 0 && newValue > -1 {
                tvEvCurrentValue.text = "0"
            } else {
                tvEvCurrentValue.text = "\(lroundf(newValue))"
            }
        }
    }
    var currentEtValue: Double = 0 {
        willSet {
            tvEtCurrentValue.text = "\(newValue)"
        }
    }
    var currentISOValue: Float = 0 {
        willSet {
            tvISOCurrentValue.text = "\(lroundf(newValue))"
        }
    }
    var currentFlValue: Float = 0 {
        willSet {
            tvFlCurrentValue.text = String(format: "%.2f", newValue)
        }
    }
    
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
        //开始预览
        cameraManager.startRunning()
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
