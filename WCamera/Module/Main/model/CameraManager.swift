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
    
    /// 构建Session
    ///
    /// - Parameter delegate: CameraManagerDelegate
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
    
    /// 开始预览
    func startRunning() {
        cameraQueue.async {
            self.captureSession.startRunning()
        }
    }
    
    /// 停止预览
    func stopRunning() {
        cameraQueue.async {
            self.captureSession.stopRunning()
        }
    }
    
    /// 根据种类和位置获取相机
    ///
    /// - Parameters:
    ///   - type: 相机种类，广角、长焦等
    ///   - position: 相机位置，前置、后置
    /// - Returns: 相机设备
    func getCaptureDevice(type: AVCaptureDevice.DeviceType, position: AVCaptureDevice.Position) -> AVCaptureDevice {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [type], mediaType: AVMediaType.video, position: position)
        if deviceDiscoverySession.devices.count != 0 {
            return deviceDiscoverySession.devices[0]
        } else {
            return AVCaptureDevice.default(for: .video)!
        }
    }
    
    /// 拍照
    func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        let photoSettings: AVCapturePhotoSettings
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings.init(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            photoSettings = AVCapturePhotoSettings.init()
        }
        photoSettings.flashMode = .auto
        if #available(iOS 12.0, *) {
            photoSettings.isAutoRedEyeReductionEnabled = photoOutput.isAutoRedEyeReductionSupported
        }
        photoSettings.isAutoStillImageStabilizationEnabled = photoOutput.isStillImageStabilizationSupported
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
}

extension AVCaptureDevice {
    /// 改变 AVCaptureDevice 的属性
    ///
    /// - Parameter configure: 闭包改变属性
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

