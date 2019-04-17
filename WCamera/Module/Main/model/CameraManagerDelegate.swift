//
//  CameraManagerDelegate.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/18.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import AVFoundation

/// CameraManager与Controller交互的协议
protocol CameraManagerDelegate: NSObjectProtocol {
    func getPreviewView() -> PreviewView
    
    func dualCameraSwitchComplete()
    
    func didFinishCapturePhoto()
    
    func didChangeEV(to value: Float)
    
    func didChangeExposureDuration(to value: CMTime)
    
    func didChangeISO(to value: Float)

    func didChangeLensPosition(to value: Float)
}
