//
//  CameraViewController+ManagerDelegate.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/27.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import UIKit
import AVFoundation

extension  CameraViewController: CameraManagerDelegate {
    /// 获取预览view
    ///
    /// - Returns: 预览的PreviewView
    func getPreviewView() -> PreviewView {
        return previewView
    }
    
    /// 双摄像头切换完成
    func dualCameraSwitchComplete() {
        switchCameraCompleteAnim { (_) in
            self.btnSwitchDualCamera?.isSelected.toggle()
            self.isCameraSwitchComplete = true
            //改变图标
            let switchDualCameraButtonImage = UserDefaults.getInt(forKey: .DualCameraType) == 0 ? UIImage.init(named: "switch_wideangle_camera") : UIImage.init(named: "switch_telephoto_camera")
            self.btnSwitchDualCamera?.setImage(switchDualCameraButtonImage, for: .normal)
        }
    }
    
    /// 切换摄像头完成后回调的统一动画
    ///
    /// - Parameter completion: 完成后的操作
    func switchCameraCompleteAnim(completion: @escaping (Bool) -> Void) {
        UIView.transition(with: previewView, duration: 0.35, options: .curveEaseIn, animations: {
            self.previewView.alpha = 1
        }, completion: completion)
    }
    
    /// 拍照完成
    func didFinishCapturePhoto() {
        DispatchQueue.main.async {
            self.previewView.isHidden = false
            self.btnCapturePhoto?.isEnabled = true
        }
    }
    
    /// 当改变EV时的回调
    ///
    /// - Parameter value: 当前的EV值
    func didChangeEvValue(to value: Float) {
        if value < 0 && value > -1 {
            tvEvCurrentValue.text = "0"
        } else {
            tvEvCurrentValue.text = "\(lroundf(value))"
        }
    }
    
    /// 当改变曝光时间时的回调
    ///
    /// - Parameter value: 当前的曝光时间
    func didChangeEtValue(to value: CMTime) {
        tvEtCurrentValue.text = DeviceUtils.getExposureDurationShowValue(value)
    }
    
    /// 当改变ISO时的回调
    ///
    /// - Parameter value: 当前的ISO
    func didChangeISOValue(to value: Float) {
        tvISOCurrentValue.text = "\(lroundf(value))"
    }
    
    /// 当改变焦距时的回调
    ///
    /// - Parameter value: 当前的焦距
    func didChangeFLValue(to value: Float) {
        tvFlCurrentValue.text = String(format: "%.2f", value)
    }
}
