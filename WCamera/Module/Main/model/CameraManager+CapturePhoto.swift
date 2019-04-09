//
//  CameraManager+CapturePhoto.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/18.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import Photos

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        //拍照完毕，但仍然在处理数据，执行动画等
        delegate?.didFinishCapturePhoto()
        //保存jpg和raw
        if let e = error {
            print(e.localizedDescription)
            return
        }
        Permission.buildPermission(type: .Photo, message: "需要您的同意来访问相册用来保存照片").request { (status) in
            guard status == .authorized else { return }
            PHPhotoLibrary.shared().performChanges({
                //将JEPG格式作为主要显示格式c保存
                guard let compressedData = self.compressedFileData else { return }
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: compressedData, options: nil)
                
                // 将Raw作为备用格式保存
                guard let rawURL = self.rawImageFileURL else { return }
                let options = PHAssetResourceCreationOptions()
                options.shouldMoveFile = true
                creationRequest.addResource(with: .alternatePhoto, fileURL: rawURL, options: options)
            }, completionHandler: { (isSuccess, error) in
                //置为nil，防止摄像头切换时判断不准确
                self.rawImageFileURL = nil
                self.compressedFileData = nil
                if let e = error {
                    fatalError(e.localizedDescription)
                }
            })
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        //保存照片
        if let e = error {
            fatalError(e.localizedDescription)
        }
        if photo.isRawPhoto {
            do {
                rawImageFileURL = self.makeUniqueTempFileURL(extension: "dng")
                try photo.fileDataRepresentation()!.write(to: rawImageFileURL!)
            } catch {
                fatalError("couldn't write DNG file to URL")
            }
        } else {
            self.compressedFileData = photo.fileDataRepresentation()!
        }
    }
    
    /// 创建一个唯一目录
    ///
    /// - Parameter type: 扩展名
    /// - Returns: 文件的URL
    func makeUniqueTempFileURL(extension type: String) -> URL {
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let uniqueFilename = ProcessInfo.processInfo.globallyUniqueString
        let urlNoExt = temporaryDirectoryURL.appendingPathComponent(uniqueFilename)
        let url = urlNoExt.appendingPathExtension(type)
        return url
    }
}
