//
//  CameraManager+CapturePhoto.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/18.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import Foundation
import Photos

extension CameraManager: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        //拍照完毕，但仍然在处理数据，执行动画等
        delegate?.didFinishCapturePhoto()
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
