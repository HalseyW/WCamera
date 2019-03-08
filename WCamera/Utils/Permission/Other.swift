//
//  other.swift
//  iOSUtils
//
//  Created by HalseyW-15 on 2018/12/18.
//  Copyright © 2018年 wushhhhhh. All rights reserved.
//
import UIKit

extension UIApplication {
     fileprivate var topViewController: UIViewController? {
        var vc = delegate?.window??.rootViewController
        while let presentedVC = vc?.presentedViewController {
            vc = presentedVC
        }
        return vc
    }
    
    func presentViewController(_ viewController: UIViewController) {
        topViewController?.present(viewController, animated: true, completion: nil)
    }
}

internal extension String {
    static let cameraUsageDescription = "NSCameraUsageDescription"
    static let micUsageDescription = "NSMicrophoneUsageDescription"
    static let photoUsageDescription = "NSPhotoLibraryUsageDescription"
    
    static let locationWhenInUseUsageDescription = "NSLocationWhenInUseUsageDescription"
    static let locationAlwaysUsageDescription = "NSLocationAlwaysUsageDescription"
    
    static let requestedNotifications = "permission.requestedNotifications"
    static let requestedLocationAlwaysWithWhenInUse = "permission.requestedLocationAlwaysWithWhenInUse"
}
