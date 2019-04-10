//
//  CameraManager.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/18.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import UIKit
import AVFoundation

class CameraManager: NSObject {
    static let shared = CameraManager()
    weak var delegate: CameraManagerDelegate?
    lazy var captureSession = AVCaptureSession.init()
    var captureDevice: AVCaptureDevice?
    var deviceInput: AVCaptureInput?
    var photoOutput: AVCapturePhotoOutput?
    lazy var cameraQueue = DispatchQueue.init(label: "com.wushhhhhh.WCamera.cameraQueue", qos: .userInteractive)
    var rawImageFileURL: URL?
    var compressedFileData: Data?
    
    func buildSession(delegate: CameraManagerDelegate) {
        self.delegate = delegate
        delegate.getPreviewView().videoPreviewLayer.session = captureSession
        cameraQueue.async {
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .photo
            //get device
            let cameraPosition: AVCaptureDevice.Position = UserDefaults.getInt(forKey: .CameraPosition) == 0 ? .back : .front
            let cameraType: AVCaptureDevice.DeviceType = UserDefaults.getInt(forKey: .DualCameraType) == 0 ? .builtInWideAngleCamera : .builtInTelephotoCamera
            self.captureDevice = cameraPosition == .front ? self.getCaptureDevice(type: .builtInWideAngleCamera, position: .front) : self.getCaptureDevice(type: cameraType, position: .back)
            //add input
            self.deviceInput = try? AVCaptureDeviceInput(device: self.captureDevice!)
            guard let deviceInput = self.deviceInput, self.captureSession.canAddInput(deviceInput) else { return }
            self.captureSession.addInput(deviceInput)
            //add output
            self.photoOutput = AVCapturePhotoOutput()
            guard let photoOutput = self.photoOutput, self.captureSession.canAddOutput(photoOutput) else {
                return
            }
            self.captureSession.addOutput(photoOutput)
            self.captureSession.commitConfiguration()
        }
    }
    
    func startRunning() {
        cameraQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopRunning() {
        cameraQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
    
    /// 切换前后置摄像头
    ///
    /// - Parameter type: 后置摄像头是长焦还是广角
    func switchFrontAndBackCamera() {
        let cameraType: AVCaptureDevice.DeviceType = UserDefaults.getInt(forKey: .DualCameraType) == 0 ? .builtInWideAngleCamera : .builtInTelephotoCamera
        captureDevice = (captureDevice?.position == .back) ? getCaptureDevice(type: .builtInWideAngleCamera, position: .front) : getCaptureDevice(type: cameraType, position: .back)
        let cameraPosition = captureDevice?.position == .back ? 0 : 1
        UserDefaults.saveInt(cameraPosition, forKey: .CameraPosition)
        switchCameraWorkFlow(to: captureDevice!) {
            self.delegate?.frontAndBackCameraSwitchComplete()
        }
    }
    
    /// 切换后置双摄
    func switchDualCamera()  {
        //如果当前是前置，就仅切换摄像头，不做更改
        if captureDevice?.position == .front {
            switchFrontAndBackCamera()
        } else {
            let cameraType: AVCaptureDevice.DeviceType = UserDefaults.getInt(forKey: .DualCameraType) == 0 ? .builtInWideAngleCamera : .builtInTelephotoCamera
            captureDevice = (cameraType == .builtInTelephotoCamera) ? getCaptureDevice(type: .builtInWideAngleCamera, position: .back) : getCaptureDevice(type: .builtInTelephotoCamera, position: .back)
            //保存设置
            let dualCameraType = captureDevice?.deviceType == .builtInWideAngleCamera ? 0 : 1
            UserDefaults.saveInt(dualCameraType, forKey: .DualCameraType)
        }
        switchCameraWorkFlow(to: captureDevice!) {
            self.delegate?.dualCameraSwitchComplete()
        }
    }
    
    /// 切换摄像头的工作流
    ///
    /// - Parameters:
    ///   - device: 切换的设备
    ///   - notify: 切换成功的回调
    func switchCameraWorkFlow(to device: AVCaptureDevice, complete notify: @escaping () -> Void) {
        let workItem = DispatchWorkItem.init {
            self.captureSession.beginConfiguration()
            self.captureSession.removeInput(self.deviceInput!)
            self.deviceInput = try? AVCaptureDeviceInput(device: device)
            guard self.captureSession.canAddInput(self.deviceInput!) else { return }
            self.captureSession.addInput(self.deviceInput!)
            self.captureSession.commitConfiguration()
        }
        cameraQueue.async(execute: workItem)
        workItem.notify(queue: DispatchQueue.main, execute: notify)
    }
    
    /// 根据相机类型和相机位置获取AVCaptureDevice
    ///
    /// - Parameters:
    ///   - type: 相机类型，长焦、广角等
    ///   - position: 相机位置，前置、后置
    /// - Returns: 相机设备AVCaptureDevice
    func getCaptureDevice(type: AVCaptureDevice.DeviceType, position: AVCaptureDevice.Position) -> AVCaptureDevice {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [type], mediaType: AVMediaType.video, position: position)
        if deviceDiscoverySession.devices.count != 0 {
            return deviceDiscoverySession.devices[0]
        } else {
            return AVCaptureDevice.default(for: .video)!
        }
    }
    
    /// 设置曝光补偿
    ///
    /// - Parameter ev: 曝光补偿度
    func changeEV(to ev: Float) {
        guard let device = captureDevice else {
            return
        }
        device.changeProperty {
            $0.setExposureTargetBias(ev) { _ in
                self.delegate?.didChangeEvValue(to: ev)
            }
        }
    }
    
    /// 设置ISO
    ///
    /// - Parameter iso: 感光度
    func changeISO(to iso: Float) {
        guard let device = captureDevice else {
            return
        }
        device.changeProperty { $0.setExposureModeCustom(duration: AVCaptureDevice.currentExposureDuration, iso: iso, completionHandler: { (_) in
            self.delegate?.didChangeISOValue(to: iso)
        })}
    }
    
    /// 设置曝光时间
    ///
    /// - Parameter duration: 曝光时间
    func changeExposureDuration(to duration: Double) {
        guard let device = captureDevice else {
            return
        }
        let durationValue = CMTimeMakeWithSeconds(duration, preferredTimescale: 1000000)
        device.changeProperty { $0.setExposureModeCustom(duration: durationValue, iso: AVCaptureDevice.currentISO, completionHandler: { (_) in
            self.delegate?.didChangeEtValue(to: duration)
        })}
    }
    
    /// 设置镜头焦距
    ///
    /// - Parameter lens: 对焦焦距
    func changeFocusLens(to lens: Float) {
        guard let device = captureDevice else {
            return
        }
        device.changeProperty {
            $0.setFocusModeLocked(lensPosition: lens) { _ in
                self.delegate?.didChangeFLValue(to: lens)
            }
        }
    }
    
    /// 点击对焦、测光
    ///
    /// - Parameter point: 点击的位置
    func focusAndExposure(at point: CGPoint) {
        guard let device = captureDevice, device.isFocusPointOfInterestSupported, device.isExposurePointOfInterestSupported else {
            return
        }
        device.changeProperty { (device) in
            let transferredPoint = delegate?.getPreviewView().transferGestureLocationToCameraPoint(point: point)
            device.focusPointOfInterest = transferredPoint!
            device.exposurePointOfInterest = transferredPoint!
            device.focusMode = .continuousAutoFocus
            device.exposureMode = .continuousAutoExposure
        }
    }
    
    /// 长按锁定焦点、曝光
    ///
    /// - Parameter point: 长按的位置
    func lockFocusAndExposure(at point: CGPoint) {
        guard let device = captureDevice, device.isFocusPointOfInterestSupported, device.isExposurePointOfInterestSupported else {
            return
        }
        device.changeProperty { (device) in
            let transferredPoint = delegate?.getPreviewView().transferGestureLocationToCameraPoint(point: point)
            device.focusPointOfInterest = transferredPoint!
            device.exposurePointOfInterest = transferredPoint!
            device.focusMode = .autoFocus
            device.exposureMode = .autoExpose
        }
    }
    
    /// 恢复自动模式
    func changeToAutoMode() {
        guard let device = captureDevice, device.position == .back else {
            return
        }
        device.changeProperty {
            $0.exposureMode = .continuousAutoExposure
            $0.focusMode = .continuousAutoFocus
            $0.setExposureTargetBias(0, completionHandler: nil)
        }
    }
    
    /// 获取正确的照片方向
    ///
    /// - Returns: 照片方向
    func getPhotoOrientation() -> AVCaptureVideoOrientation {
        let deviceOritation = UIDevice.current.orientation
        switch deviceOritation {
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return .portrait
        }
    }
    
    /// 拍摄照片
    func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        let photoSettings: AVCapturePhotoSettings
        if let availableRawFormat = photoOutput.availableRawPhotoPixelFormatTypes.first { //查到支持的RAW格式
            // 如果用HEIC保存照片，会导致部分修图程序读不出RAW数据
            photoSettings = AVCapturePhotoSettings(rawPixelFormatType: availableRawFormat, processedFormat: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        } else {//如果不支持RAW拍摄，则回落到HEIC
            if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            } else {
                photoSettings = AVCapturePhotoSettings()
            }
        }
        //设置闪光灯模式
        let flashMode = UserDefaults.getInt(forKey: .FlashMode)
        photoSettings.flashMode = AVCaptureDevice.FlashMode(rawValue: flashMode)!
        //根据设备方向来设置照片方向，使得照片方向始终为竖屏
        photoOutput.connection(with: .video)?.videoOrientation = getPhotoOrientation()
        //此处必须设置为 false，否则设备会对 iso 和曝光时长进行修改
        photoSettings.isAutoStillImageStabilizationEnabled = false
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
}

extension AVCaptureDevice {
    func changeProperty(_ configure: (AVCaptureDevice) -> Void) {
        do {
            try lockForConfiguration()
            configure(self)
            unlockForConfiguration()
        } catch  let error as NSError{
            print("CaptureDevice属性修改失败: \(error)")
        }
    }
}
