//
//  CameraViewController.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/8.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController {
    override var prefersStatusBarHidden: Bool { return true }
    var previewView: PreviewView?
    var btnCapturePhoto: UIButton?
    var btnSwitchDualCamera: UIButton?
    var btnSwitchFrontAndBackCamera: UIButton?
    var ivFocus: UIImageView?
    var sliderISO: UISlider?
    var sliderExposureDuration: UISlider?
    let cameraManager = CameraManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        cameraManager.buildSession(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cameraManager.startRunning()
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        cameraManager.stopRunning()
        super.viewWillDisappear(animated)
    }
    
    /// 点击拍照按钮
    @objc func onClickCapturePhotoButton() {
        cameraManager.capturePhoto()
    }
    
    //切换前/后置摄像头
    @objc func onClickSwitchFrontAndBackCameraButton() {
        switchCameraAnim {
            self.btnCapturePhoto?.isEnabled = false
            self.btnSwitchFrontAndBackCamera?.isEnabled = false
            self.previewView?.alpha = 0
            self.cameraManager.switchFrontAndBackCamera()
        }
    }
    
    //切换后置双摄
    @objc func onClickSwitchDualCameraButton() {
        switchCameraAnim {
            self.btnCapturePhoto?.isEnabled = false
            self.btnSwitchDualCamera?.isEnabled = false
            self.previewView?.alpha = 0
            self.cameraManager.switchDualCamera()
        }
    }
    
    /// 切换摄像头的统一动画
    ///
    /// - Parameter anim: 执行的操作
    func switchCameraAnim(anim: @escaping () -> Void) {
        UIView.transition(with: previewView!, duration: 0.2, options: .curveEaseOut, animations: anim, completion: nil)
    }
    
    /// 切换摄像头完成后回调的统一动画
    ///
    /// - Parameter completion: 完成后的操作
    func switchCameraCompleteAnim(completion: @escaping (Bool) -> Void) {
        UIView.transition(with: previewView!, duration: 0.35, options: .curveEaseIn, animations: {
            self.previewView?.alpha = 1
        }, completion: completion)
    }
    
    /// 拖动ISO和快门时间调整滑块
    @objc func isoAndExposureDurationValueDidChange() {
        let sliderISOValue = sliderISO!.value
        let sliderExposureDurationValue = sliderExposureDuration!.value
        cameraManager.changeISOAndExposureDuration(duration: Double(sliderExposureDurationValue), iso: sliderISOValue)
    }
    
    /// 点击预览界面，对焦、测光
    ///
    /// - Parameter sender: 点击手势
    @objc func onTapPreviewView(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let point = sender.location(in: previewView)
            cameraManager.focusAndExposure(at: point)
        }
    }
    
    /// 长按预览界面，锁定焦点、曝光
    ///
    /// - Parameter sender: 长按手势
    @objc func onLongPressPreviewView(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let point = sender.location(in: previewView)
            cameraManager.lockFocusAndExposure(at: point)
        }
    }
}

extension  CameraViewController: CameraManagerDelegate {
    func getPreviewView() -> PreviewView {
        return previewView!
    }
    
    func getCapturePhotoButton() -> UIButton {
        return btnCapturePhoto!
    }
    
    func frontAndBackCameraSwitchComplete() {
        switchCameraCompleteAnim { (_) in
            self.btnSwitchFrontAndBackCamera?.isSelected.toggle()
            self.btnCapturePhoto?.isEnabled = true
            self.btnSwitchFrontAndBackCamera?.isEnabled = true
        }
    }
    
    func dualCameraSwitchComplete() {
        switchCameraCompleteAnim { (_) in
            self.btnSwitchDualCamera?.isSelected.toggle()
            self.btnCapturePhoto?.isEnabled = true
            self.btnSwitchDualCamera?.isEnabled = true
        }
    }
}
