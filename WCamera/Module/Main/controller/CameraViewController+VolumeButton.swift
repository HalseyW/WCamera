//
//  CameraViewController+VolumeButton.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/27.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import UIKit

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
    
    /// 应用进入后台。将currentValue设为-1，重置获取到的系统音量，防止用户在其他地方修改了音量，再回到应用时的音量错误。
    ///
    /// - Parameter notification: 通知
    @objc func didEnterBackground(notification: Notification) {
        currentVolume = -1
    }
    
    /// 按下了实体音量键盘
    ///
    /// - Parameter notification: 通知
    @objc func onPressVolumeButton(notification: Notification) {
        guard let session = previewView.videoPreviewLayer.session, session.isRunning, btnCapturePhoto!.isEnabled else { return }
        onClickCapturePhotoButton()
        //第一次进入应用或者应用进入后台，currentVolume都将被重置为-1
        if currentVolume == -1 {
            currentVolume = getMPVolumeSlider().value
        }
        getMPVolumeSlider().value = currentVolume
    }
}
