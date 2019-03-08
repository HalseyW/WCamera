//
//  PermissionUtils.swift
//  iOSUtils
//
//  Created by Wushhhhhh on 2017/8/25.
//  Copyright © 2018年 wushhhhhh. All rights reserved.
//
//1. 非必要权限，在用的地方请求，且只请求一次。
//2. 必要权限先提示再请求，被拒绝时弹框并提供跳转到设置的选项。
//3. 多个必要权限，单独界面提供单独按钮，点击按钮后请求，被拒绝时弹框并提供跳转到设置的选项。
import Foundation
import UIKit

class Permission: NSObject {
    //回调
    internal typealias Callback = (PermissionStatus) -> Void
    var callback: Callback?
    //拒绝/取消/预先提醒的提示框
    lazy var deniedAlert: DeniedAlert = {return DeniedAlert(permissionUtils: self)}()
    lazy var cancelAlert: CancelAlert = {return CancelAlert(permissionUtils: self)}()
    lazy var preAlert: PreAlert = {return PreAlert(permissionUtils: self)}()
    var shouldPresentDeniedAlert = true
    var shouldPresentCancelAlert = true
    var shouldPresentPreAlert = true
    //权限类型
    let permissionType: PermissionType
    //权限状态
    var permissionStatus: PermissionStatus {
        switch permissionType {
        case .Camera:
            return cameraPermissionStatus
        case .Mic:
            return micPermissionStatus
        case .Photo:
            return photoPermissionStatus
        }
    }

    init(type: PermissionType) {
        self.permissionType = type
    }
    
    /**
     暴露的请求接口
     */
    func request(_ callback: @escaping Callback) {
        self.callback = callback
        let status = permissionStatus
        switch status {
        case .authorized:
            callbacks(status)
        case .denied:
            shouldPresentDeniedAlert ? deniedAlert.present() : callbacks(status)
        case .notDetermined:
            shouldPresentCancelAlert ? preAlert.present() : requestPermission(callbacks(_:))
        case .restricted:
            shouldPresentPreAlert ? cancelAlert.present() : callbacks(status)
        }
    }
    
    /**
     根据类型判断请求方法
     */
    internal func requestPermission(_ callback: @escaping Callback) {
        switch permissionType {
        case .Camera:
            requestCamera(callback)
        case .Mic:
            requestMic(callback)
        case .Photo:
            requestPhotos(callback)
        }
    }
    
    /**
     回调方法
     */
    internal func callbacks(_ with: PermissionStatus) {
        DispatchQueue.main.async {
            self.callback?(self.permissionStatus)
        }
    }
}
