//
//  ViewController.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/8.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import UIKit
import SnapKit

/// 权限请求Controller
class PermissionViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    var btnCameraPermission: UIButton?
    var btnMicPermission: UIButton?
    var btnPhotoPermission: UIButton?
    /// 权限
    var cameraPermission: Permission {
        return buildPermission(type: .Camera, message: "需要您的授权才能使用照相机进行拍照")
    }
    var micPermission: Permission {
        return buildPermission(type: .Mic, message: "需要您的授权才能使用麦克风进行录音")
    }
    var photoPermission: Permission {
        return buildPermission(type: .Photo, message: "需要您的授权才能访问相册用来保存照片")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    @objc func onClickCameraPermissionButton(sender: UIButton) {
        requestPermission(permisson: cameraPermission, button: sender)
    }
    
    @objc func onClickMicPermissionButton(sender: UIButton) {
        requestPermission(permisson: micPermission, button: sender)
    }

    @objc func onClickPhotoPermissionButton(sender: UIButton) {
        requestPermission(permisson: photoPermission, button: sender)
    }
    
    /// 请求权限
    ///
    /// - Parameters:
    ///   - permisson: 权限工具类
    ///   - button: 根据权限的授权情况改变按钮的状态
    func requestPermission(permisson: Permission, button: UIButton) {
        permisson.request {
            button.backgroundColor = ($0 != .authorized) ? UIColor.init(r: 255, g: 77, b: 0, alpha: 1) : UIColor.init(r: 0, g: 238, b: 180, alpha: 1)
            //如果全部授权则进入主界面
            if self.cameraPermission.permissionStatus == .authorized
                && self.micPermission.permissionStatus == .authorized
                && self.photoPermission.permissionStatus == .authorized {
                self.present(CameraViewController.init(), animated: false, completion: nil)
            }
        }
    }
    
    /// 构建权限工具类
    ///
    /// - Parameters:
    ///   - type: 权限的类型
    ///   - message: 权限被拒绝后Alert的message
    /// - Returns: 权限工具类
    func buildPermission(type: PermissionType, message: String) -> Permission {
        let permission = Permission.init(type: type)
        permission.shouldPresentPreAlert = false
        permission.shouldPresentCancelAlert = false
        permission.deniedAlert.title = "权限获取失败"
        permission.deniedAlert.message = message
        permission.deniedAlert.defaulCancelActionTitle = "取消"
        permission.deniedAlert.defaultActionTitle = "设置"
        return permission
    }
}

extension PermissionViewController {
    func initView() {
        self.view.backgroundColor = .black
        //麦克风权限按钮
        btnMicPermission = UIButton.init()
        btnMicPermission?.getPermissionButton(title: "麦克风", status: micPermission.permissionStatus)
        self.view.addSubview(btnMicPermission!)
        btnMicPermission?.snp.makeConstraints({ (make) in
            make.width.equalToSuperview().offset(-80)
            make.height.equalTo(44)
            make.center.equalToSuperview()
        })
        btnMicPermission?.addTarget(self, action: #selector(onClickMicPermissionButton(sender:)), for: .touchUpInside)
        //相机权限按钮
        btnCameraPermission = UIButton.init()
        btnCameraPermission?.getPermissionButton(title: "相机", status: cameraPermission.permissionStatus)
        self.view.addSubview(btnCameraPermission!)
        btnCameraPermission?.snp.makeConstraints({ (make) in
            make.width.equalToSuperview().offset(-80)
            make.height.equalTo(44)
            make.centerX.equalTo(btnMicPermission!)
            make.bottom.equalTo(btnMicPermission!.snp.top).offset(-30)
        })
        btnCameraPermission?.addTarget(self, action: #selector(onClickCameraPermissionButton(sender:)), for: .touchUpInside)
        //照片权限按钮
        btnPhotoPermission = UIButton.init()
        btnPhotoPermission?.getPermissionButton(title: "相册", status: photoPermission.permissionStatus)
        self.view.addSubview(btnPhotoPermission!)
        btnPhotoPermission?.snp.makeConstraints({ (make) in
            make.width.equalToSuperview().offset(-80)
            make.height.equalTo(44)
            make.centerX.equalTo(btnMicPermission!)
            make.top.equalTo(btnMicPermission!.snp.bottom).offset(30)
        })
        btnPhotoPermission?.addTarget(self, action: #selector(onClickPhotoPermissionButton(sender:)), for: .touchUpInside)
    }
}

extension UIButton {
    
    /// 构建权限请求按钮
    ///
    /// - Parameters:
    ///   - title: UIButton的title
    ///   - status: 权限的授权状态，根据状态设置按钮的颜色
    func getPermissionButton(title: String, status: PermissionStatus) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.backgroundColor = (status != .authorized) ? UIColor.init(r: 255, g: 77, b: 0, alpha: 1) : UIColor.init(r: 0, g: 238, b: 180, alpha: 1)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
    }
}
