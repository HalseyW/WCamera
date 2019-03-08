//
//  ViewController.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/8.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let cameraPersmission = Permission.init(type: .Camera)
        let micPermission = Permission.init(type: .Mic)
        let photoPermission = Permission.init(type: .Photo)
        
        cameraPersmission.shouldPresentCancelAlert = false
        cameraPersmission.deniedAlert.defaulCancelActionTitle = "取消"
        cameraPersmission.deniedAlert.message = "需要您的允许才能访问并上传数据"
        cameraPersmission.deniedAlert.title = "需要使用相机的权限"
        cameraPersmission.deniedAlert.defaultActionTitle = "去设置"
        
        micPermission.shouldPresentCancelAlert = false
        micPermission.deniedAlert.defaulCancelActionTitle = "取消"
        micPermission.deniedAlert.message = "需要您的允许才能访问并上传数据"
        micPermission.deniedAlert.title = "需要访问相册的权限"
        micPermission.deniedAlert.defaultActionTitle = "去设置"
        
        photoPermission.shouldPresentCancelAlert = false
        photoPermission.deniedAlert.defaulCancelActionTitle = "取消"
        photoPermission.deniedAlert.message = "需要您的允许才能访问并上传数据"
        photoPermission.deniedAlert.title = "需要访问相册的权限"
        photoPermission.deniedAlert.defaultActionTitle = "去设置"
        
        cameraPersmission.request { (status) in
            
        }
        micPermission.request { (status) in
            
        }
        photoPermission.request { (status) in
            
        }
    }


}

