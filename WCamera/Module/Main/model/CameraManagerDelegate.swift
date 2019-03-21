//
//  CameraManagerDelegate.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/18.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import Foundation
import UIKit

/// CameraManager与Controller交互的协议
protocol CameraManagerDelegate: NSObjectProtocol {
    func getPreviewView() -> PreviewView
    
    func getCapturePhotoButton() -> UIButton
    
    func frontAndBackCameraSwitchComplete()
    
    func dualCameraSwitchComplete()
}
