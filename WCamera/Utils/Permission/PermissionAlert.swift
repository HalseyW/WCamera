//
//  PermissionAlert.swift
//  iOSUtils
//
//  Created by HalseyW-15 on 2018/12/18.
//  Copyright © 2018年 wushhhhhh. All rights reserved.
//

import Foundation
import UIKit

internal class PermissionAlert {
    fileprivate let permissionUtils: Permission
    fileprivate var status: PermissionStatus {return permissionUtils.permissionStatus}
    fileprivate var type: PermissionType {return permissionUtils.permissionType}
    fileprivate var callbacks: Permission.Callback {return permissionUtils.callbacks}
    
    var title = "This is a dedault title"
    var message = "This is a dedault message"
    var defaulCancelActionTitle = "Cancel"
    
    fileprivate init(permissionUtils: Permission) {
        self.permissionUtils = permissionUtils
    }
    
    fileprivate var controller: UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: defaulCancelActionTitle, style: .cancel, handler: cancelHandler)
        controller.addAction(cancelAction)
        return controller
    }
    
    private func cancelHandler(_ action: UIAlertAction) {
        callbacks(status)
    }
    
    func present() {
        DispatchQueue.main.async {
            UIApplication.shared.presentViewController(self.controller)
        }
    }
}

class DeniedAlert: PermissionAlert {
    var defaultActionTitle = "Setting"
    
    internal override init(permissionUtils: Permission) {
        super.init(permissionUtils: permissionUtils)
    }
    
    fileprivate override var controller: UIAlertController {
        let controller = super.controller
        let defaultAction = UIAlertAction(title: defaultActionTitle, style: .default, handler: jumpToSettionHandler)
        controller.addAction(defaultAction)
        return controller
    }
    
    private func jumpToSettionHandler(_ action: UIAlertAction) {
        if let URL = URL(string: UIApplication.openSettingsURLString) {
            NotificationCenter.default.addObserver(self, selector: #selector(self.backFromSetting(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
            UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        }
    }
    
    @objc private func backFromSetting(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        callbacks(status)
    }
}

class CancelAlert: PermissionAlert {
    internal override init(permissionUtils: Permission) {
        super.init(permissionUtils: permissionUtils)
    }
}

class PreAlert: PermissionAlert {
    var defaultConfirmActionTitle = "Confirm"
    
    internal override init(permissionUtils: Permission) {
        super.init(permissionUtils: permissionUtils)
    }
    
    fileprivate override var controller: UIAlertController {
        let controller = super.controller
        let defaultAction = UIAlertAction(title: defaultConfirmActionTitle, style: .default, handler: confirmHandler)
        controller.addAction(defaultAction)
        return controller
    }
    
    private func confirmHandler(_ action: UIAlertAction) {
        permissionUtils.requestPermission(callbacks)
    }
}
