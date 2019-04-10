//
//  CameraViewController+click.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/27.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import UIKit
import AVFoundation

extension CameraViewController {
    /// 切换闪光灯模式
    @IBAction func onClickFlashModeChangeButton(_ sender: UIButton) {
        var flashMode = UserDefaults.getInt(forKey: .FlashMode)
        flashMode = (flashMode + 1) % 3
        UserDefaults.saveInt(flashMode, forKey: .FlashMode)
        btnFlashMode?.setImage(flashModeButtonImages[flashMode], for: .normal)
    }
    
    //切换前/后置摄像头
    @IBAction func onClickSwitchFrontAndBackCameraButton() {
        switchCameraUIWorkFlow {
            self.cameraManager.switchFrontAndBackCamera()
            self.ivFocus?.isHidden = true
        }
    }
    
    //切换后置双摄
    @IBAction func onClickSwitchDualCameraButton() {
        switchCameraUIWorkFlow {
            self.cameraManager.switchDualCamera()
        }
    }
    
    /// 点击拍照按钮
    @IBAction func onClickCapturePhotoButton() {
        cameraManager.capturePhoto()
        btnCapturePhoto?.isEnabled = false
        previewView.isHidden = true
        tapticEngineGenerator.impactOccurred()
    }
    
    /// 切换摄像头的统一动画
    ///
    /// - Parameter anim: 执行的操作
    func switchCameraUIWorkFlow(anim: @escaping () -> Void) {
        self.isCameraSwitchComplete = false
        self.previewView.alpha = 0
        self.tapticEngineGenerator.impactOccurred()
        UIView.transition(with: previewView, duration: 0.2, options: .curveEaseOut, animations: anim, completion: nil)
    }
    
    /// 恢复自动模式
    @IBAction func onClickAutoModeButton() {
        ivFocus?.isHidden = true
        uiManualOpt.isHidden = true
        sliderMode = -1
        tvEvCurrentValue.text = "0"
        tvEtCurrentValue.text = "自动"
        tvISOCurrentValue.text = "自动"
        tvFlCurrentValue.text = "自动"
        cameraManager.changeToAutoMode()
        tapticEngineGenerator.impactOccurred()
    }
    
    /// 点击预览界面，对焦、测光
    ///
    /// - Parameter sender: 点击手势
    @IBAction func onTapPreviewView(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let point = sender.location(in: previewView)
            cameraManager.focusAndExposure(at: point)
            setFocusImageViewWhenFocusing(to: point, use: UIImage.init(named: "focus")!)
        }
    }
    
    /// 长按预览界面，锁定焦点、曝光
    ///
    /// - Parameter sender: 长按手势
    @IBAction func onLongPressPreviewView(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let point = sender.location(in: previewView)
            cameraManager.lockFocusAndExposure(at: point)
            setFocusImageViewWhenFocusing(to: point, use: UIImage.init(named: "focus_locked")!)
        }
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
    
    /// 点击了调节EV的模块
    @IBAction func onClickExposureValueView() {
        guard let device = cameraManager.captureDevice, sliderMode != 0 else { return }
        let min = device.minExposureTargetBias
        let max = device.maxExposureTargetBias
        sliderMode = 0
        toggleManualOptSlider(value: 0, min: min, max: max)
    }
    
    /// 点击了调节ET的模块
    @IBAction func onClickExposureTimeView() {
        guard let device = cameraManager.captureDevice, sliderMode != 1 else { return }
        let min = CMTimeGetSeconds(device.activeFormat.minExposureDuration)
        let max = CMTimeGetSeconds(device.activeFormat.maxExposureDuration)
        sliderMode = 1
        toggleManualOptSlider(value: 0, min: Float(min), max: Float(max))
    }
    
    /// 点击了调节ISO的模块
    @IBAction func onClickISOView() {
        guard let device = cameraManager.captureDevice, sliderMode != 2 else { return }
        let min = device.activeFormat.minISO
        let max = device.activeFormat.maxISO
        sliderMode = 2
        toggleManualOptSlider(value: 0, min: min, max: max)
    }
    
    /// 点击了调节FL的模块
    @IBAction func onClickFocusLenthView() {
        guard sliderMode != 3 else { return }
        sliderMode = 3
        toggleManualOptSlider(value: 0, min: 0, max: 1)
    }
    
    func toggleManualOptSlider(value: Float, min: Float, max: Float) {
        uiManualOpt.isHidden = false
        sliderManualOpt.minimumValue = min
        sliderManualOpt.maximumValue = max
        sliderManualOpt.value = value
        tvSliderMinValue.text = "\(lroundf(min))"
        tvSliderMaxValue.text = "\(lroundf(max))"
    }
    
    /// 手动控制时滑动滑条的回调
    ///
    /// - Parameter sender: 滑条
    @IBAction func onSlideManualOptSlider(_ sender: UISlider) {
        let value = sender.value
        switch sliderMode {
        case 0:
            cameraManager.changeEV(to: value)
        case 1:
            let time = Double(String(format: "%.6f", value))!
            cameraManager.changeExposureDuration(to: time)
        case 2:
            cameraManager.changeISO(to: value)
        case 3:
            cameraManager.changeFocusLens(to: value)
        default:
            break
        }
    }
}
