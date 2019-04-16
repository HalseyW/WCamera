//
//  CameraViewController+VolumeButton.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/27.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import MediaPlayer

extension CameraViewController {
    /// 获取MPVolumeView中的音量调节Slider
    ///
    /// - Returns: 系统音量调节Slider
    func getMPVolumeSlider() -> UISlider {
        var slider = UISlider.init()
        for view in mpVolumeView!.subviews {
            if type(of: view).description() == "MPVolumeSlider" {
                slider = view as! UISlider
                return slider
            }
        }
        return slider
    }
    
    /// 获取系统当前音量，用以在应用退出或进入后台时恢复用户设置的音量
    ///
    /// - Returns: 系统当前音量
    func getCurrentVolume() -> Float {
        do {
            try AVAudioSession.sharedInstance().setActive(true, options: .init())
            try AVAudioSession.sharedInstance().setCategory(.ambient)
        } catch {
            fatalError("AVAudioSession set active error")
        }
        return AVAudioSession.sharedInstance().outputVolume
    }
    
    /// 按下了实体音量键盘
    ///
    /// - Parameter notification: 通知
    @objc func onPressVolumeButton(notification: Notification) {
        guard canCaptureWhenPressVolumeButton else { return }
        onClickCapturePhotoButton()
    }
}
