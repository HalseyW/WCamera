//
//  CameraViewController+View.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/18.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import UIKit
import SnapKit
import MediaPlayer

extension CameraViewController {
    func initView() {
        //覆盖系统音量按钮
        mpVolumeView = MPVolumeView.init(frame: CGRect.init(x: -100, y: -100, width: 0, height: 0))
        mpVolumeView!.showsRouteButton = false
        mpVolumeView!.showsVolumeSlider = true
        self.view.addSubview(mpVolumeView!)
        //闪光灯按钮
        let flashMode = UserDefaults.getInt(forKey: .FlashMode)
        btnFlashMode?.setImage(flashModeButtonImages[flashMode], for: .normal)
        //切换广角和长焦摄像头
        let switchDualCameraButtonImage = UserDefaults.getInt(forKey: .DualCameraType) == 0 ? UIImage.init(named: "switch_wideangle_camera") : UIImage.init(named: "switch_telephoto_camera")
        btnSwitchDualCamera?.setImage(switchDualCameraButtonImage, for: .normal)
        //手动操作设置区域
        uiManualOpt = UIView.init()
        self.view.addSubview(uiManualOpt!)
        uiManualOpt!.snp.makeConstraints({ (make) in
            make.width.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalTo(btnCapturePhoto!.snp.top).offset(-10)
        })
        //Exp调整
        let uiEv = UIView.init()
        uiEv.setManualOptItem(superView: uiManualOpt!, leftView: nil)
        tvEvTitle = UILabel.init()
        tvEvTitle?.getManualOptItemTitle(superView: uiEv, title: "Exp")
        tvEv = UILabel.init()
        tvEv?.getManualOptItemText(superView: uiEv, label: tvEvTitle!, title: "0.0")
        evBottomLine = UIView.init()
        evBottomLine?.setManualOptItemBottomLine(superView: uiEv)
        //Sec调整
        let uiEt = UIView.init()
        uiEt.setManualOptItem(superView: uiManualOpt!, leftView: uiEv)
        tvEtTitle = UILabel.init()
        tvEtTitle?.getManualOptItemTitle(superView: uiEt, title: "Sec")
        tvEt = UILabel.init()
        tvEt?.getManualOptItemText(superView: uiEt, label: tvEtTitle!, title: "自动")
        etBottomLine = UIView.init()
        etBottomLine?.setManualOptItemBottomLine(superView: uiEt)
        //ISO调整
        let uiIso = UIView.init()
        uiIso.setManualOptItem(superView: uiManualOpt!, leftView: uiEt)
        tvIsoTitle = UILabel.init()
        tvIsoTitle?.getManualOptItemTitle(superView: uiIso, title: "ISO")
        tvIso = UILabel.init()
        tvIso?.getManualOptItemText(superView: uiIso, label: tvIsoTitle!, title: "自动")
        isoBottomLine = UIView.init()
        isoBottomLine?.setManualOptItemBottomLine(superView: uiIso)
        //FL调整
        let uiFocus = UIView.init()
        uiFocus.setManualOptItem(superView: uiManualOpt!, leftView: uiIso)
        tvFocusTitle = UILabel.init()
        tvFocusTitle?.getManualOptItemTitle(superView: uiFocus, title: "FL")
        tvFocus = UILabel.init()
        tvFocus?.getManualOptItemText(superView: uiFocus, label: tvFocusTitle!, title: "自动")
        focusBottomLine = UIView.init()
        focusBottomLine?.setManualOptItemBottomLine(superView: uiFocus)
        //添加点击手势
        uiEv.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onTapExpView(sender:))))
        uiEt.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onTapSecView(sender:))))
        uiIso.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onTapISOView(sender:))))
        uiFocus.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onTapFLView(sender:))))
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
