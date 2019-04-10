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
    }
}
