//
//  CameraViewController+View.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/18.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

extension CameraViewController {
    func initView() {
        self.view.backgroundColor = .black
        //顶部view
        uiTopView = UIView.init()
        self.view.addSubview(uiTopView!)
        uiTopView?.snp.makeConstraints({ (make) in
            make.width.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        })
        //闪光灯按钮
        btnFlashMode = UIButton.init()
        let flashMode = UserDefaults.getInt(forKey: .FlashMode)
        switch flashMode {
        case 0:
            btnFlashMode?.setBackgroundImage(UIImage.init(named: "flash_off"), for: .normal)
        case 1:
            btnFlashMode?.setBackgroundImage(UIImage.init(named: "flash_on"), for: .normal)
        case 2:
            btnFlashMode?.setBackgroundImage(UIImage.init(named: "flash_auto"), for: .normal)
        default:
            break
        }
        uiTopView?.addSubview(btnFlashMode!)
        btnFlashMode?.snp.makeConstraints({ (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(22)
            make.width.equalTo(22)
        })
        btnFlashMode?.addTarget(self, action: #selector(onClickChangeFlashModeButton), for: .touchUpInside)
        //切换前后摄像头
        btnSwitchFrontAndBackCamera = UIButton.init()
        btnSwitchFrontAndBackCamera?.setBackgroundImage(UIImage.init(named: "switch_camera"), for: .normal)
        uiTopView?.addSubview(btnSwitchFrontAndBackCamera!)
        btnSwitchFrontAndBackCamera?.snp.makeConstraints({ (make) in
            make.width.equalTo(22)
            make.height.equalTo(22)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
        })
        btnSwitchFrontAndBackCamera?.addTarget(self, action: #selector(onClickSwitchFrontAndBackCameraButton), for: .touchUpInside)
        //预览层
        previewView = PreviewView()
        self.view.addSubview(previewView!)
        previewView?.snp.makeConstraints({ (make) in
            make.width.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.width * 4 / 3)
            make.top.equalTo(uiTopView!.snp.bottom)
        })
        previewView?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onTapPreviewView(sender:))))
        previewView?.addGestureRecognizer(UILongPressGestureRecognizer.init(target: self, action: #selector(onLongPressPreviewView(sender:))))
        //拍照按钮
        btnCapturePhoto = UIButton.init()
        btnCapturePhoto?.setBackgroundImage(UIImage.init(named: "capture"), for: .normal)
        self.view.addSubview(btnCapturePhoto!)
        btnCapturePhoto?.snp.makeConstraints({ (make) in
            make.width.equalTo(70)
            make.height.equalTo(70)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        })
        btnCapturePhoto?.addTarget(self, action: #selector(onClickCapturePhotoButton), for: .touchUpInside)
        //切换广角和长焦摄像头
        btnSwitchDualCamera = UIButton.init()
        let switchDualCameraButtonImage = UserDefaults.getInt(forKey: .DualCameraType) == 0 ? UIImage.init(named: "switch_wideangle_camera") : UIImage.init(named: "switch_telephoto_camera")
        btnSwitchDualCamera?.setBackgroundImage(switchDualCameraButtonImage, for: .normal)
        self.view.addSubview(btnSwitchDualCamera!)
        btnSwitchDualCamera?.snp.makeConstraints({ (make) in
            make.width.equalTo(22)
            make.height.equalTo(22)
            make.centerY.equalTo(btnCapturePhoto!)
            make.right.equalToSuperview().offset(-UIScreen.main.bounds.width / 4 + 11)
        })
        btnSwitchDualCamera?.addTarget(self, action: #selector(onClickSwitchDualCameraButton), for: .touchUpInside)
        //对焦框
        ivFocus = UIImageView.init()
        ivFocus?.image = UIImage.init(named: "focus")
        previewView?.addSubview(ivFocus!)
        ivFocus?.snp.makeConstraints({ (make) in
            make.width.equalTo(150)
            make.height.equalTo(150)
            make.center.equalToSuperview()
        })
        ivFocus?.isHidden = true
//        //iso滑条
//        sliderISO = UISlider.init()
//        sliderISO?.minimumTrackTintColor = .lightGray
//        sliderISO?.maximumTrackTintColor = .lightGray
//        self.view.addSubview(sliderISO!)
//        sliderISO?.snp.makeConstraints({ (make) in
//            make.width.equalToSuperview().offset(-60)
//            make.centerX.equalToSuperview()
//            make.top.equalTo(previewView!.snp.bottom).offset(20)
//        })
//        sliderISO?.addTarget(self, action: #selector(isoAndExposureDurationValueDidChange), for: .valueChanged)
//        //曝光时间滑条
//        sliderExposureDuration = UISlider.init()
//        sliderExposureDuration?.minimumTrackTintColor = .lightGray
//        sliderExposureDuration?.maximumTrackTintColor = .lightGray
//        self.view.addSubview(sliderExposureDuration!)
//        sliderExposureDuration?.snp.makeConstraints({ (make) in
//            make.width.equalToSuperview().offset(-60)
//            make.centerX.equalToSuperview()
//            make.top.equalTo(sliderISO!.snp.bottom).offset(20)
//        })
//        sliderExposureDuration?.addTarget(self, action: #selector(isoAndExposureDurationValueDidChange), for: .valueChanged)
    }
}
