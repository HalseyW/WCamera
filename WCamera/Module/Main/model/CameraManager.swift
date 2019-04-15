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
    var cameraQueue = DispatchQueue.init(label: "com.wushhhhhh.WCamera.cameraQueue")
    var rawImageFileURL: URL?
    var compressedFileData: Data?
    var minEV: Float?
    var maxEV: Float?
    var minEt: Float?
    var maxEt: Float?
    var minEtForLabel: String?
    var maxEtForLabel: String?
    var minISO: Float?
    var maxISO: Float?
    
    func buildSession(delegate: CameraManagerDelegate) {
        self.delegate = delegate
        delegate.getPreviewView().videoPreviewLayer.session = captureSession
        cameraQueue.async {
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .photo
            //get device
            let cameraType: AVCaptureDevice.DeviceType = UserDefaults.getInt(forKey: .DualCameraType) == 0 ? .builtInWideAngleCamera : .builtInTelephotoCamera
            self.captureDevice = self.getCaptureDevice(type: cameraType, position: .back)
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
    
    /// 切换后置双摄
    func switchDualCamera()  {
        //根据用户设置获取摄像头
        let cameraType: AVCaptureDevice.DeviceType = UserDefaults.getInt(forKey: .DualCameraType) == 0 ? .builtInWideAngleCamera : .builtInTelephotoCamera
        captureDevice = (cameraType == .builtInTelephotoCamera) ? getCaptureDevice(type: .builtInWideAngleCamera, position: .back) : getCaptureDevice(type: .builtInTelephotoCamera, position: .back)
        //保存设置
        let dualCameraType = captureDevice?.deviceType == .builtInWideAngleCamera ? 0 : 1
        UserDefaults.saveInt(dualCameraType, forKey: .DualCameraType)
        //开始切换
        captureSession.beginConfiguration()
        captureSession.removeInput(deviceInput!)
        deviceInput = try? AVCaptureDeviceInput(device: captureDevice!)
        guard captureSession.canAddInput(deviceInput!) else { return }
        captureSession.addInput(deviceInput!)
        captureSession.commitConfiguration()
        delegate?.dualCameraSwitchComplete()
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
        guard let device = captureDevice else {
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
