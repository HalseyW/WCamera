//
//  CameraManagerDelegate.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/18.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import Foundation

/// CameraManager与Controller交互的协议
protocol CameraManagerDelegate: NSObjectProtocol {
    func getPreviewView() -> PreviewView
    
    func frontAndBackCameraSwitchComplete()
    
    func dualCameraSwitchComplete()
    
    func didFinishCapturePhoto()
    
    func didChangeEvValue(to value: Float)
    
    func didChangeEtValue(to value: Double)
    
    func didChangeISOValue(to value: Float)

    func didChangeFLValue(to value: Float)
}
