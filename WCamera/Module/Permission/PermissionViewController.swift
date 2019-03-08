//
//  ViewController.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/8.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import UIKit
import SnapKit

class PermissionViewController: UIViewController {
    var btnCameraPermission: UIButton?
    var btnMicPermission: UIButton?
    var btnPhotoPermission: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }

}

extension PermissionViewController {
    func initView() {
        self.view.backgroundColor = .white
        btnMicPermission = UIButton.init()
        btnMicPermission?.getPermissionButton(title: "麦克风")
        self.view.addSubview(btnMicPermission!)
        btnMicPermission?.snp.makeConstraints({ (make) in
            make.width.equalToSuperview().offset(-60)
            make.height.equalTo(50)
            make.center.equalToSuperview()
        })
        
        btnCameraPermission = UIButton.init()
        btnCameraPermission?.getPermissionButton(title: "相机")
        self.view.addSubview(btnCameraPermission!)
        btnCameraPermission?.snp.makeConstraints({ (make) in
            make.width.equalToSuperview().offset(-60)
            make.height.equalTo(50)
            make.centerX.equalTo(btnMicPermission!)
            make.bottom.equalTo(btnMicPermission!.snp.top).offset(-30)
        })
        
        btnPhotoPermission = UIButton.init()
        btnPhotoPermission?.getPermissionButton(title: "相册")
        self.view.addSubview(btnPhotoPermission!)
        btnPhotoPermission?.snp.makeConstraints({ (make) in
            make.width.equalToSuperview().offset(-60)
            make.height.equalTo(50)
            make.centerX.equalTo(btnMicPermission!)
            make.top.equalTo(btnMicPermission!.snp.bottom).offset(30)
        })
        
    }
}

extension UIButton {
    func getPermissionButton(title: String) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = .red
    }
}
