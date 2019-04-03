//
//  CameraViewController+ManagerDelegate.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/27.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import UIKit

extension  CameraViewController: CameraManagerDelegate {
    /// 获取预览view
    ///
    /// - Returns: 预览的PreviewView
    func getPreviewView() -> PreviewView {
        return previewView
    }
    
    /// 前/后置摄像头切换完成
    func frontAndBackCameraSwitchComplete() {
        switchCameraCompleteAnim { (_) in
            self.btnSwitchFrontAndBackCamera?.isSelected.toggle()
            self.isCameraSwitchComplete = true
        }
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
}
