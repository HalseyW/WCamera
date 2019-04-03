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
import MediaPlayer

extension CameraViewController {
    func initView() {
        self.view.backgroundColor = .black
        //顶部view
        let uiTopView = UIView.init()
        self.view.addSubview(uiTopView)
        uiTopView.snp.makeConstraints({ (make) in
            make.width.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        })
        //预览层
        self.view.addSubview(previewView)
        previewView.snp.makeConstraints({ (make) in
            make.width.equalToSuperview()
            make.height.equalTo(DeviceUtils.screenWidth * 4 / 3)
            make.top.equalTo(uiTopView.snp.bottom)
        })
        previewView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onTapPreviewView(sender:))))
        previewView.addGestureRecognizer(UILongPressGestureRecognizer.init(target: self, action: #selector(onLongPressPreviewView(sender:))))
        //覆盖系统音量按钮
        mpVolumeView = MPVolumeView.init(frame: CGRect.init(x: -100, y: -100, width: 0, height: 0))
        mpVolumeView!.showsRouteButton = false
        mpVolumeView!.showsVolumeSlider = true
        self.view.addSubview(mpVolumeView!)
        //九宫格辅助线
        let ivAuxiliaryLine = UIImageView.init()
        ivAuxiliaryLine.image = UIImage.init(named: "auxiliary_line")
        self.previewView.addSubview(ivAuxiliaryLine)
        ivAuxiliaryLine.snp.makeConstraints { (make) in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        }
        //闪光灯按钮
        btnFlashMode = UIButton.init()
        let flashMode = UserDefaults.getInt(forKey: .FlashMode)
        switch flashMode {
        case 0:
            btnFlashMode?.setImage(UIImage.init(named: "flash_off"), for: .normal)
        case 1:
            btnFlashMode?.setImage(UIImage.init(named: "flash_on"), for: .normal)
        case 2:
            btnFlashMode?.setImage(UIImage.init(named: "flash_auto"), for: .normal)
        default:
            break
        }
        uiTopView.addSubview(btnFlashMode!)
        btnFlashMode?.snp.makeConstraints({ (make) in
            make.width.equalTo(44)
            make.height.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        })
        btnFlashMode?.addTarget(self, action: #selector(onClickChangeFlashModeButton), for: .touchUpInside)
        //切换前后摄像头
        btnSwitchFrontAndBackCamera = UIButton.init()
        btnSwitchFrontAndBackCamera?.setImage(UIImage.init(named: "switch_camera"), for: .normal)
        uiTopView.addSubview(btnSwitchFrontAndBackCamera!)
        btnSwitchFrontAndBackCamera?.snp.makeConstraints({ (make) in
            make.width.equalTo(44)
            make.height.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(10)
        })
        btnSwitchFrontAndBackCamera?.addTarget(self, action: #selector(onClickSwitchFrontAndBackCameraButton), for: .touchUpInside)
        //拍照按钮
        btnCapturePhoto = UIButton.init()
        btnCapturePhoto?.setImage(UIImage.init(named: "capture"), for: .normal)
        self.view.addSubview(btnCapturePhoto!)
        btnCapturePhoto?.snp.makeConstraints({ (make) in
            make.size.equalTo(CGSize.init(width: 70, height: 70))
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        })
        btnCapturePhoto?.addTarget(self, action: #selector(onClickCapturePhotoButton), for: .touchUpInside)
        //切换广角和长焦摄像头
        btnSwitchDualCamera = UIButton.init()
        let switchDualCameraButtonImage = UserDefaults.getInt(forKey: .DualCameraType) == 0 ? UIImage.init(named: "switch_wideangle_camera") : UIImage.init(named: "switch_telephoto_camera")
        btnSwitchDualCamera?.setImage(switchDualCameraButtonImage, for: .normal)
        self.view.addSubview(btnSwitchDualCamera!)
        btnSwitchDualCamera?.snp.makeConstraints({ (make) in
            make.size.equalTo(CGSize.init(width: 50, height: 50))
            make.centerY.equalTo(btnCapturePhoto!)
            make.right.equalToSuperview().inset(DeviceUtils.screenWidth / 4 - 25)
        })
        btnSwitchDualCamera?.addTarget(self, action: #selector(onClickSwitchDualCameraButton), for: .touchUpInside)
        //自动模式
        btnAutoMode = UIButton.init()
        btnAutoMode?.setImage(UIImage.init(named: "auto_mode"), for: .normal)
        self.view.addSubview(btnAutoMode!)
        btnAutoMode?.snp.makeConstraints({ (make) in
            make.size.equalTo(CGSize.init(width: 50, height: 50))
            make.centerY.equalTo(btnCapturePhoto!)
            make.left.equalToSuperview().inset(DeviceUtils.screenWidth / 4 - 25)
        })
        btnAutoMode?.addTarget(self, action: #selector(onClickAutoModeButton), for: .touchUpInside)
        //对焦框
        ivFocus = UIImageView.init()
        ivFocus?.image = UIImage.init(named: "focus")
        previewView.addSubview(ivFocus!)
        ivFocus?.snp.makeConstraints({ (make) in
            make.size.equalTo(CGSize.init(width: 150, height: 150))
            make.center.equalToSuperview()
        })
        ivFocus?.isHidden = true
        //手动操作设置区域
        let uiManualOpt = UIView.init()
        self.view.addSubview(uiManualOpt)
        uiManualOpt.snp.makeConstraints({ (make) in
            make.width.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalTo(btnCapturePhoto!.snp.top).offset(-10)
        })
        //Exp调整
        let uiEv = UIView.init()
        uiEv.setManualOptItem(superView: uiManualOpt, leftView: nil)
        tvEvTitle = UILabel.init()
        tvEvTitle?.getManualOptItemTitle(superView: uiEv, title: "Exp")
        tvEv = UILabel.init()
        tvEv?.getManualOptItemText(superView: uiEv, label: tvEvTitle!, title: "0.0")
        evBottomLine = UIView.init()
        evBottomLine?.setManualOptItemBottomLine(superView: uiEv)
        //Sec调整
        let uiEt = UIView.init()
        uiEt.setManualOptItem(superView: uiManualOpt, leftView: uiEv)
        tvEtTitle = UILabel.init()
        tvEtTitle?.getManualOptItemTitle(superView: uiEt, title: "Sec")
        tvEt = UILabel.init()
        tvEt?.getManualOptItemText(superView: uiEt, label: tvEtTitle!, title: "自动")
        etBottomLine = UIView.init()
        etBottomLine?.setManualOptItemBottomLine(superView: uiEt)
        //ISO调整
        let uiIso = UIView.init()
        uiIso.setManualOptItem(superView: uiManualOpt, leftView: uiEt)
        tvIsoTitle = UILabel.init()
        tvIsoTitle?.getManualOptItemTitle(superView: uiIso, title: "ISO")
        tvIso = UILabel.init()
        tvIso?.getManualOptItemText(superView: uiIso, label: tvIsoTitle!, title: "自动")
        isoBottomLine = UIView.init()
        isoBottomLine?.setManualOptItemBottomLine(superView: uiIso)
        //FL调整
        let uiFocus = UIView.init()
        uiFocus.setManualOptItem(superView: uiManualOpt, leftView: uiIso)
        tvFocusTitle = UILabel.init()
        tvFocusTitle?.getManualOptItemTitle(superView: uiFocus, title: "FL")
        tvFocus = UILabel.init()
        tvFocus?.getManualOptItemText(superView: uiFocus, label: tvFocusTitle!, title: "自动")
        focusBottomLine = UIView.init()
        focusBottomLine?.setManualOptItemBottomLine(superView: uiFocus)
    }
}

extension UIView {
    func setManualOptItem(superView: UIView, leftView: UIView?) {
        superView.addSubview(self)
        self.snp.makeConstraints({ (make) in
            make.width.equalToSuperview().dividedBy(4)
            make.height.centerY.equalToSuperview() //centerY为必要语句，否则会在 11.4 上造成错位
            if let view = leftView {
                make.left.equalTo(view.snp.right)
            } else {
                make.left.equalToSuperview()
            }
        })
    }
    
    func setManualOptItemBottomLine(superView: UIView) {
        superView.addSubview(self)
        self.snp.makeConstraints({ (make) in
            make.width.equalToSuperview().inset(30)
            make.height.equalTo(3)
            make.bottom.centerX.equalToSuperview()//centerY必要语句，否则会在 11.4 上造成错位
        })
    }
}

extension UILabel {
    func getManualOptItemTitle(superView: UIView, title: String) {
        self.text = title
        self.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        self.textColor = .white
        self.textAlignment = .center
        superView.addSubview(self)
        self.snp.makeConstraints({ (make) in
            make.width.centerX.equalToSuperview() //centerX为必要语句，否则会在 11.4 上造成错位
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(3)
        })
    }
    
    func getManualOptItemText(superView: UIView, label: UILabel, title: String) {
        self.text = title
        self.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        self.textColor = .white
        self.textAlignment = .center
        superView.addSubview(self)
        self.snp.makeConstraints({ (make) in
            make.width.centerX.equalToSuperview() //centerX为必要语句，否则会在 11.4 上造成错位
            make.top.equalTo(label.snp.bottom)
        })
    }
}
