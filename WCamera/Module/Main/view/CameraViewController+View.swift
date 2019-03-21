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
        //预览层
        previewView = PreviewView()
        self.view.addSubview(previewView!)
        previewView?.snp.makeConstraints({ (make) in
            make.width.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.width * 4 / 3)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        })
        previewView?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onTapPreviewView(sender:))))
        previewView?.addGestureRecognizer(UILongPressGestureRecognizer.init(target: self, action: #selector(onLongPressPreviewView(sender:))))
        //拍照按钮
        btnCapturePhoto = UIButton.init()
        btnCapturePhoto?.setTitle("拍照", for: .normal)
        btnCapturePhoto?.setTitle("处理中...", for: .disabled)
        btnCapturePhoto?.setTitleColor(.white, for: .normal)
        btnCapturePhoto?.backgroundColor = .blue
        self.view.addSubview(btnCapturePhoto!)
        btnCapturePhoto?.snp.makeConstraints({ (make) in
            make.width.equalTo(100)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        })
        btnCapturePhoto?.addTarget(self, action: #selector(onClickCapturePhotoButton), for: .touchUpInside)
        //切换前后摄像头
        btnSwitchFrontAndBackCamera = UIButton.init()
        btnSwitchFrontAndBackCamera?.setTitle("后置", for: .normal)
        btnSwitchFrontAndBackCamera?.setTitle("前焦", for: .selected)
        btnSwitchFrontAndBackCamera?.setTitleColor(.white, for: .normal)
        btnSwitchFrontAndBackCamera?.backgroundColor = .green
        self.view.addSubview(btnSwitchFrontAndBackCamera!)
        btnSwitchFrontAndBackCamera?.snp.makeConstraints({ (make) in
            make.width.equalTo(50)
            make.height.equalTo(35)
            make.centerY.equalTo(btnCapturePhoto!)
            make.right.equalTo(btnCapturePhoto!.snp.left).offset(-20)
        })
        btnSwitchFrontAndBackCamera?.addTarget(self, action: #selector(onClickSwitchFrontAndBackCameraButton), for: .touchUpInside)
        //切换广角和长焦摄像头
        btnSwitchDualCamera = UIButton.init()
        btnSwitchDualCamera?.setTitle("广角", for: .normal)
        btnSwitchDualCamera?.setTitle("长焦", for: .selected)
        btnSwitchDualCamera?.setTitleColor(.white, for: .normal)
        btnSwitchDualCamera?.backgroundColor = .green
        self.view.addSubview(btnSwitchDualCamera!)
        btnSwitchDualCamera?.snp.makeConstraints({ (make) in
            make.width.equalTo(50)
            make.height.equalTo(35)
            make.centerY.equalTo(btnCapturePhoto!)
            make.left.equalTo(btnCapturePhoto!.snp.right).offset(20)
        })
        btnSwitchDualCamera?.addTarget(self, action: #selector(onClickSwitchDualCameraButton), for: .touchUpInside)
        //iso滑条
        sliderISO = UISlider.init()
        sliderISO?.minimumTrackTintColor = .lightGray
        sliderISO?.maximumTrackTintColor = .lightGray
        self.view.addSubview(sliderISO!)
        sliderISO?.snp.makeConstraints({ (make) in
            make.width.equalToSuperview().offset(-60)
            make.centerX.equalToSuperview()
            make.top.equalTo(previewView!.snp.bottom).offset(20)
        })
        sliderISO?.addTarget(self, action: #selector(isoAndExposureDurationValueDidChange), for: .valueChanged)
        //曝光时间滑条
        sliderExposureDuration = UISlider.init()
        sliderExposureDuration?.minimumTrackTintColor = .lightGray
        sliderExposureDuration?.maximumTrackTintColor = .lightGray
        self.view.addSubview(sliderExposureDuration!)
        sliderExposureDuration?.snp.makeConstraints({ (make) in
            make.width.equalToSuperview().offset(-60)
            make.centerX.equalToSuperview()
            make.top.equalTo(sliderISO!.snp.bottom).offset(20)
        })
        sliderExposureDuration?.addTarget(self, action: #selector(isoAndExposureDurationValueDidChange), for: .valueChanged)
    }
}
