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
    
    func getCaptureDevice(type: AVCaptureDevice.DeviceType, position: AVCaptureDevice.Position) -> AVCaptureDevice {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [type], mediaType: AVMediaType.video, position: position)
        if deviceDiscoverySession.devices.count != 0 {
            return deviceDiscoverySession.devices[0]
        } else {
            return AVCaptureDevice.default(for: .video)!
        }
    }
    
    func changeEV(device: AVCaptureDevice, ev: Float) {
        guard ev >= device.minExposureTargetBias && ev <= device.maxExposureTargetBias else {
            return
        }
        device.changeProperty {
            $0.setExposureTargetBias(ev, completionHandler: nil)
        }
    }
    
    func changeISO(device: AVCaptureDevice, iso: Float) {
        guard iso >= device.activeFormat.minISO && iso <= device.activeFormat.maxISO else {
            return
        }
        device.changeProperty {
            $0.setExposureModeCustom(duration: device.exposureDuration, iso: iso, completionHandler: nil)
        }
    }
    
    func changeExposureDuration(device: AVCaptureDevice, duration: CMTime) {
        guard duration >= device.activeFormat.minExposureDuration && duration <= device.activeFormat.maxExposureDuration else {
            return
        }
        device.changeProperty {
            $0.setExposureModeCustom(duration: duration, iso: device.iso, completionHandler: nil)
        }
    }
    
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

