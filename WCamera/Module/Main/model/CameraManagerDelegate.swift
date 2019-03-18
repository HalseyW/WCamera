//
//  CameraManagerDelegate.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/18.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import Foundation
import UIKit

protocol CameraManagerDelegate: NSObjectProtocol {
    func getPreviewView() -> PreviewView
    
    func getCapturePhotoButton() -> UIButton
}
