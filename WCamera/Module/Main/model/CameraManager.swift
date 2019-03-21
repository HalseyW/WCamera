//
//  CameraManager.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/18.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraManager: NSObject {
    static let shared = CameraManager()
    weak var delegate: CameraManagerDelegate?
    let captureSession = AVCaptureSession.init()
    var captureDevice: AVCaptureDevice?
    var deviceInput: AVCaptureInput?
    var photoOutput: AVCapturePhotoOutput?
    let cameraQueue = DispatchQueue.init(label: "com.wushhhhhh.WCamera.cameraQueue")
    
    func buildSession(delegate: CameraManagerDelegate) {
        self.delegate = delegate
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        //get device
        captureDevice = getCaptureDevice(type: .builtInWideAngleCamera, position: .back)
        //add input
        deviceInput = try? AVCaptureDeviceInput(device: captureDevice!)
        guard let deviceInput = deviceInput, captureSession.canAddInput(deviceInput) else { return }
        captureSession.addInput(deviceInput)
        //add output
        photoOutput = AVCapturePhotoOutput()
        guard let photoOutput = photoOutput, captureSession.canAddOutput(photoOutput) else {
            return
        }
        captureSession.addOutput(photoOutput)
        captureSession.commitConfiguration()
        delegate.getPreviewView().videoPreviewLayer.session = captureSession
    }
    
    func startRunning() {
        cameraQueue.async {
            self.captureSession.startRunning()
        }
    }
    
    func stopRunning() {
        cameraQueue.async {
            self.captureSession.stopRunning()
        }
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
        let minEV = device.minExposureTargetBias
        let maxEV = device.maxExposureTargetBias
        let value = ev * (maxEV - minEV) + minEV
        device.changeProperty { $0.setExposureTargetBias(value, completionHandler: nil) }
    }
    
    /// 设置ISO和快门时间
    ///
    /// - Parameters:
    ///   - duration: 快门时间
    ///   - iso: ISO
    func changeISOAndExposureDuration(duration: Double, iso: Float) {
        guard let device = captureDevice else {
            return
        }
        //计算ISO
        let minISO = device.activeFormat.minISO
        let maxISO = device.activeFormat.maxISO
        let isoValue = round(iso * (maxISO - minISO) + minISO)
        //计算快门时间
        let minDuration = CMTimeGetSeconds(device.activeFormat.minExposureDuration)
        let maxDuration = CMTimeGetSeconds(device.activeFormat.maxExposureDuration)
        let durationValueSeconds = duration * (maxDuration - minDuration) + minDuration
        let durationValue = CMTimeMakeWithSeconds(durationValueSeconds, preferredTimescale: 1000000)
        device.changeProperty { $0.setExposureModeCustom(duration: durationValue, iso: isoValue, completionHandler: nil) }
    }
    
    /// 点击对焦、测光
    ///
    /// - Parameter point: 点击的位置
    func focusAndExposure(at point: CGPoint) {
        
    }
    
    /// 长按锁定焦点、曝光
    ///
    /// - Parameter point: 长按的位置
    func lockFocusAndExposure(at point: CGPoint) {
        
    }
    
    /// 拍摄照片
    func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        let photoSettings: AVCapturePhotoSettings
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings.init(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            photoSettings = AVCapturePhotoSettings.init()
        }
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
