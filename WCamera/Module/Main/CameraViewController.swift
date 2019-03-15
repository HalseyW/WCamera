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
    var previewView: PreviewView?
    var btnCapturePhoto: UIButton?
    var photoOutput: AVCapturePhotoOutput?

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
        let captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
        guard let deviceInput = try? AVCaptureDeviceInput(device: device!), captureSession.canAddInput(deviceInput) else { return }
        captureSession.addInput(deviceInput)
         photoOutput = AVCapturePhotoOutput()
        guard let photoOutput = photoOutput, captureSession.canAddOutput(photoOutput) else {
            return
        }
        captureSession.addOutput(photoOutput)
        captureSession.commitConfiguration()
        previewView?.videoPreviewLayer.session = captureSession
        captureSession.startRunning()
        
//        changeDeviceProperty(captureDevice: device!) {
//            $0.setExposureModeCustom(duration: AVCaptureDevice.currentExposureDuration, iso: (device?.activeFormat.maxISO)!, completionHandler: nil)
//            $0.setExposureModeCustom(duration: (device?.activeFormat.minExposureDuration)!, iso: AVCaptureDevice.currentISO, completionHandler: nil)
//        }
        
    }
    
    @objc func onClickCapturePhotoButton() {
        capturePhoto()
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
    
    func changeDeviceProperty(captureDevice: AVCaptureDevice, change: (AVCaptureDevice) -> Void) {
        do {
            try captureDevice.lockForConfiguration()
            change(captureDevice)
            captureDevice.unlockForConfiguration()
        } catch  let error as NSError{
            print("CaptureDevice属性修改失败: \(error)")
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        //开始拍照，执行动画等
        btnCapturePhoto?.isEnabled = false
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        //拍照完毕，但仍然在处理数据，执行动画等
        btnCapturePhoto?.isEnabled = true
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        //保存照片
        if let e = error {
            print(e.localizedDescription)
            return
        }
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: photo.fileDataRepresentation()!, options: nil)
        }) { (isSuccess, error) in
            if let e = error {
                print("Capture Error: \(e.localizedDescription)")
            }
        }
    }
}

extension CameraViewController {
    func initView() {
        self.view.backgroundColor = .black
        //预览层
        previewView = PreviewView()
        self.view.addSubview(previewView!)
        previewView?.snp.makeConstraints({ (make) in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        })
        //拍照按钮
        btnCapturePhoto = UIButton.init()
        btnCapturePhoto?.setTitle("拍照", for: .normal)
        btnCapturePhoto?.setTitle("处理中...", for: .disabled)
        btnCapturePhoto?.setTitleColor(.white, for: .normal)
        btnCapturePhoto?.backgroundColor = .blue
        self.view.addSubview(btnCapturePhoto!)
        btnCapturePhoto?.snp.makeConstraints({ (make) in
            make.width.equalTo(100)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        })
        btnCapturePhoto?.addTarget(self, action: #selector(onClickCapturePhotoButton), for: .touchUpInside)
    }
}
