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
        //iso滑条
        sliderISO = UISlider.init()
        sliderISO?.minimumTrackTintColor = .lightGray
        sliderISO?.maximumTrackTintColor = .lightGray
        self.view.addSubview(sliderISO!)
        sliderISO?.snp.makeConstraints({ (make) in
            make.width.equalToSuperview().offset(-60)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(btnCapturePhoto!.snp.top).offset(-20)
        })
        sliderISO?.addTarget(self, action: #selector(isoSliderValueDidChange(sender:)), for: .valueChanged)
    }
}
