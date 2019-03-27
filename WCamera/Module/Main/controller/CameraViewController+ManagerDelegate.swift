//
//  CameraViewController+ManagerDelegate.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/27.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import Foundation
import UIKit

extension  CameraViewController: CameraManagerDelegate {
    func getPreviewView() -> PreviewView {
        return previewView
    }
    
    func frontAndBackCameraSwitchComplete() {
        switchCameraCompleteAnim { (_) in
            self.btnSwitchFrontAndBackCamera?.isSelected.toggle()
            self.btnCapturePhoto?.isEnabled = true
            self.btnSwitchFrontAndBackCamera?.isEnabled = true
            self.btnSwitchDualCamera?.isEnabled = true
        }
    }
    
    func dualCameraSwitchComplete() {
        switchCameraCompleteAnim { (_) in
            self.btnSwitchDualCamera?.isSelected.toggle()
            self.btnCapturePhoto?.isEnabled = true
            self.btnSwitchFrontAndBackCamera?.isEnabled = true
            self.btnSwitchDualCamera?.isEnabled = true
            //改变图标
            let switchDualCameraButtonImage = UserDefaults.getInt(forKey: .DualCameraType) == 0 ? UIImage.init(named: "switch_wideangle_camera") : UIImage.init(named: "switch_telephoto_camera")
            self.btnSwitchDualCamera?.setImage(switchDualCameraButtonImage, for: .normal)
        }
    }
    
    func didFinishCapturePhoto() {
        DispatchQueue.main.async {
            self.previewView.isHidden = false
            self.btnCapturePhoto?.isEnabled = true
        }
    }
}
