//
//  CameraViewController+click.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/27.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import Foundation
import UIKit

extension CameraViewController {
    /// 切换闪光灯模式
    @objc func onClickChangeFlashModeButton() {
        var flashMode = UserDefaults.getInt(forKey: .FlashMode)
        var flashModeButtonImage: UIImage?
        switch flashMode {
        case 0:
            flashMode = 1
            flashModeButtonImage = UIImage.init(named: "flash_on")
        case 1:
            flashMode = 2
            flashModeButtonImage = UIImage.init(named: "flash_auto")
        case 2:
            flashMode = 0
            flashModeButtonImage = UIImage.init(named: "flash_off")
        default:
            break
        }
        UserDefaults.saveInt(flashMode, forKey: .FlashMode)
        btnFlashMode?.setImage(flashModeButtonImage, for: .normal)
    }
    
    //切换前/后置摄像头
    @objc func onClickSwitchFrontAndBackCameraButton() {
        switchCameraAnim {
            self.ivFocus?.isHidden = true
            self.btnCapturePhoto?.isEnabled = false
            self.btnSwitchFrontAndBackCamera?.isEnabled = false
            self.btnSwitchDualCamera?.isEnabled = false
            self.previewView.alpha = 0
            self.cameraManager.switchFrontAndBackCamera()
            self.tapticEngineGenerator.impactOccurred()
        }
    }
    
    /// 点击拍照按钮
    @objc func onClickCapturePhotoButton() {
        btnCapturePhoto?.isEnabled = false
        cameraManager.capturePhoto()
        previewView.isHidden = true
        tapticEngineGenerator.impactOccurred()
    }
    
    /// 恢复自动模式
    @objc func onClickAutoModeButton() {
        ivFocus?.isHidden = true
        cameraManager.changeToAutoMode()
        tapticEngineGenerator.impactOccurred()
    }
    
    //切换后置双摄
    @objc func onClickSwitchDualCameraButton() {
        switchCameraAnim {
            self.btnCapturePhoto?.isEnabled = false
            self.btnSwitchFrontAndBackCamera?.isEnabled = false
            self.btnSwitchDualCamera?.isEnabled = false
            self.previewView.alpha = 0
            self.cameraManager.switchDualCamera()
            self.tapticEngineGenerator.impactOccurred()
        }
    }
    
    /// 点击预览界面，对焦、测光
    ///
    /// - Parameter sender: 点击手势
    @objc func onTapPreviewView(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let point = sender.location(in: previewView)
            cameraManager.focusAndExposure(at: point)
            setFocusImageViewWhenFocusing(to: point, use: UIImage.init(named: "focus")!)
        }
    }
    
    /// 长按预览界面，锁定焦点、曝光
    ///
    /// - Parameter sender: 长按手势
    @objc func onLongPressPreviewView(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let point = sender.location(in: previewView)
            cameraManager.lockFocusAndExposure(at: point)
            setFocusImageViewWhenFocusing(to: point, use: UIImage.init(named: "focus_locked")!)
        }
    }
    
    /// 切换摄像头的统一动画
    ///
    /// - Parameter anim: 执行的操作
    func switchCameraAnim(anim: @escaping () -> Void) {
        UIView.transition(with: previewView, duration: 0.2, options: .curveEaseOut, animations: anim, completion: nil)
    }
    
    /// 切换摄像头完成后回调的统一动画
    ///
    /// - Parameter completion: 完成后的操作
    func switchCameraCompleteAnim(completion: @escaping (Bool) -> Void) {
        UIView.transition(with: previewView, duration: 0.35, options: .curveEaseIn, animations: {
            self.previewView.alpha = 1
        }, completion: completion)
    }
    
    /// 对焦时设置对焦框的状态
    ///
    /// - Parameters:
    ///   - center: 对焦框的位置
    ///   - image:  对焦框的图片，锁定和点击对焦
    func setFocusImageViewWhenFocusing(to center: CGPoint, use image: UIImage) {
        //如果正在运行动画，则停止当前动画，防连击
        if let animator = focusImageViewTapAnimator, animator.isRunning {
            animator.stopAnimation(true)
        }
        //设置对焦框状态和位置
        ivFocus?.center = center
        ivFocus?.isHidden = false
        ivFocus?.image = image
        ivFocus?.bounds.size = CGSize.init(width: 150, height: 150)
        //执行动画
        focusImageViewTapAnimator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.ivFocus?.bounds.size = CGSize.init(width: 90, height: 90)
        }, completion: nil)
    }
}
