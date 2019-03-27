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
    var uiTopView: UIView?
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
    let mpVolumeView = MPVolumeView.init(frame: CGRect.init(x: -100, y: -100, width: 0, height: 0))
    let cameraManager = CameraManager.shared
    lazy var tapticEngineGenerator = UIImpactFeedbackGenerator.init(style: .light)
    var focusImageViewTapAnimator: UIViewPropertyAnimator?
    lazy var currentVolume: Float = -1
    
    override func viewDidLoad() {
        cameraManager.buildSession(delegate: self)
        super.viewDidLoad()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cameraManager.startRunning()
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //按下实体音量键监听
        NotificationCenter.default.addObserver(self, selector: #selector(onPressVolumeButton(notification:)), name: NSNotification.Name.init("AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        //进入后台监听
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        cameraManager.stopRunning()
        super.viewWillDisappear(animated)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
}
