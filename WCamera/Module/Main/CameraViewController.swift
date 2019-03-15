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
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified)
        guard let deviceInput = try? AVCaptureDeviceInput(device: device!), captureSession.canAddInput(deviceInput) else { return }
        captureSession.addInput(deviceInput)
         photoOutput = AVCapturePhotoOutput()
        guard let photoOutput = photoOutput, captureSession.canAddOutput(photoOutput) else {
            return
        }
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        captureSession.commitConfiguration()
        previewView?.videoPreviewLayer.session = captureSession
        captureSession.startRunning()
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
        photoSettings.isAutoStillImageStabilizationEnabled = photoOutput.isStillImageStabilizationSupported
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let e = error {
            print(e.localizedDescription)
            return
        }
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: photo.fileDataRepresentation()!, options: nil)
        }) { (isSuccess, error) in
            if isSuccess {
                print("Capture Success")
            }
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
