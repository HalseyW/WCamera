//
//  DeviceUtils.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/25.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import Foundation
import UIKit

class DeviceUtils {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.width
    
    static func isNotchDevice() -> Bool {
        guard #available(iOS 11.0, *), let window = UIApplication.shared.delegate?.window else {
            return false
        }
        return window?.safeAreaInsets.bottom != 0
    }
}
