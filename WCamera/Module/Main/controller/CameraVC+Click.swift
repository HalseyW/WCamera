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
    
    //切换后置双摄
    @IBAction func onClickSwitchDualCameraButton() {
        onClickAutoModeButton()
        self.btnCapturePhoto?.isEnabled = false
        self.btnSwitchDualCamera?.isEnabled = false
        self.cameraManager.switchDualCamera()
    }
    
    /// 点击拍照按钮
    @IBAction func onClickCapturePhotoButton() {
        cameraManager.capturePhoto()
        btnCapturePhoto?.isEnabled = false
        previewView.isHidden = true
        tapticEngineGenerator.impactOccurred()
    }
    
    /// 恢复自动模式
    @IBAction func onClickAutoModeButton() {
        cameraManager.changeToAutoMode()
        ivFocus?.isHidden = true
        uiManualOpt.isHidden = true
        manualOptMode = -1
        tvEvCurrentValue.text = "0.0"
        tvEtCurrentValue.text = "自动"
        tvISOCurrentValue.text = "自动"
        tvFlCurrentValue.text = "自动"
        tapticEngineGenerator.impactOccurred()
    }
    
    /// 点击预览界面，对焦、测光
    ///
    /// - Parameter sender: 点击手势
    @IBAction func onTapPreviewView(sender: UITapGestureRecognizer) {
        if sender.state == .ended && uiManualOpt.isHidden {
            let point = sender.location(in: previewView)
            cameraManager.focusAndExposure(at: point)
            setFocusImageViewWhenFocusing(to: point, use: UIImage.init(named: "focus")!)
        }
    }
    
    /// 长按预览界面，锁定焦点、曝光
    ///
    /// - Parameter sender: 长按手势
    @IBAction func onLongPressPreviewView(sender: UILongPressGestureRecognizer) {
        if sender.state == .began && uiManualOpt.isHidden {
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
        focusImageViewTapAnimator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.ivFocus?.bounds.size = CGSize.init(width: 90, height: 90)
        }, completion: nil)
    }

    /// 点击了手动操作区域，根据tag判断点击的是哪个区域
    ///
    /// - Parameter sender: 单击手势
    @IBAction func onClickManualOptView(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        let newSliderMode = view.tag
        if manualOptMode != newSliderMode {
            manualOptMode = newSliderMode
            setManualOptView()
        }
    }
    
    /// 改变滑块的状态
    ///
    /// - Parameters:
    ///   - value: 滑条的初始值
    ///   - min: 滑条的最小值
    ///   - max: 滑条的最大值
    func setManualOptView() {
        switch manualOptMode {
        case 0:
            let evValues = cameraManager.getDeivceLimitEV()
            setManualOptSliderAndLabe(with: evValues.min, evValues.max, evValues.current, label: "\(lroundf(evValues.min))", "\(lroundf(evValues.max))")
        case 1:
            let edValue = cameraManager.getDeivceLimitExposureDuration()
            setManualOptSliderAndLabe(with: edValue.min, edValue.max, edValue.current, label: edValue.minLabel, edValue.maxLabel)
        case 2:
            let isoValues = cameraManager.getDeivceLimitISO()
            setManualOptSliderAndLabe(with: isoValues.min, isoValues.max, isoValues.current, label: "\(lroundf(isoValues.min))", "\(lroundf(isoValues.max))")
        case 3:
            let lpValue = cameraManager.getDeivceLimitLensPosition()
            setManualOptSliderAndLabe(with: lpValue.min, lpValue.max, lpValue.current, label: "\(lroundf(lpValue.min))", "\(lroundf(lpValue.max))")
        default:
            break
        }
    }
    
    /// 设置slider和Slider上方UILabel的最小/最大/当前值
    ///
    /// - Parameters:
    ///   - sliderMin: slider最小值
    ///   - sliderMax: slider最大值
    ///   - sliderValue: slider当前值
    ///   - minLabel: 该属性的最小值
    ///   - maxLabel: 该属性的最大值
    func setManualOptSliderAndLabe(with sliderMin: Float, _ sliderMax: Float, _ sliderValue: Float, label minLabel: String, _ maxLabel: String) {
        //设置slider
        sliderManualOpt.minimumValue = sliderMin
        sliderManualOpt.maximumValue = sliderMax
        sliderManualOpt.value = sliderValue
        //设置UILabel
        tvSliderMinValue.text = minLabel
        tvSliderMaxValue.text = maxLabel
        UIView.transition(with: uiManualOpt, duration: 0.2, options: [.curveEaseIn], animations: {
            self.uiManualOpt.isHidden = false
            self.uiManualOpt.alpha = 0
            self.uiManualOpt.alpha = 1
        }, completion: nil)
    }
    
    /// 手动控制时滑动滑条的回调
    ///
    /// - Parameter sender: 滑条
    @IBAction func onSlideManualOptSlider(_ sender: UISlider) {
        let value = sender.value
        switch manualOptMode {
        case 0:
            cameraManager.changeEV(to: value)
        case 1:
            let time = Double(String(format: "%.6f", value))!
            cameraManager.changeExposureDuration(to: time)
        case 2:
            cameraManager.changeISO(to: value)
        case 3:
            cameraManager.changeLensPosition(to: value)
        default:
            break
        }
    }
}
