//
//  CameraPermission.swift
//  iOSUtils
//
//  Created by HalseyW-15 on 2018/12/18.
//  Copyright © 2018年 wushhhhhh. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

//Camera
extension Permission {
    var cameraPermissionStatus: PermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized: return .authorized
        case .denied: return .denied
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        }
    }
    
    func requestCamera(_ callback: @escaping Callback) {
        guard let _ = Bundle.main.object(forInfoDictionaryKey: String.cameraUsageDescription) else {
            print("WARNING: \(String.cameraUsageDescription) is missing in Info.plist")
            return
        }
        AVCaptureDevice.requestAccess(for: .video) { (_) in
            callback(self.cameraPermissionStatus)
        }
    }
}

//Microphone
extension Permission {
    var micPermissionStatus: PermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .authorized: return .authorized
        case .denied: return .denied
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        }
    }
    
    func requestMic(_ callback: @escaping Callback) {
        guard let _ = Bundle.main.object(forInfoDictionaryKey: String.micUsageDescription) else {
            print("WARNING: \(String.micUsageDescription) is missing in Info.plist")
            return
        }
        AVCaptureDevice.requestAccess(for: .audio) { (_) in
            callback(self.cameraPermissionStatus)
        }
    }
}

//Photo
extension Permission {
    var photoPermissionStatus: PermissionStatus {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized: return .authorized
        case .denied: return .denied
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        }
    }
    
    func requestPhotos(_ callback: @escaping Callback) {
        guard let _ = Bundle.main.object(forInfoDictionaryKey: String.photoUsageDescription) else {
            print("WARNING: \(String.photoUsageDescription) not found in Info.plist")
            return
        }
        
        PHPhotoLibrary.requestAuthorization { _ in
            callback(self.photoPermissionStatus)
        }
    }
}
