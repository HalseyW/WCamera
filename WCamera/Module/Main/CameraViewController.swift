//
//  CameraViewController.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/8.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    var previewView: PreviewView?

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
        let captureSession = AVCaptureSession()
        
        captureSession.beginConfiguration()
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified)
        guard let deviceInput = try? AVCaptureDeviceInput(device: device!), captureSession.canAddInput(deviceInput) else { return }
        captureSession.addInput(deviceInput)
        
        let photoOutput = AVCapturePhotoOutput()
        guard captureSession.canAddOutput(photoOutput) else {
            return
        }
        
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        captureSession.commitConfiguration()
        
        previewView?.videoPreviewLayer.session = captureSession
        
        captureSession.startRunning()
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
    }
}
