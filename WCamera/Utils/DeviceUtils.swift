//
//  DeviceUtils.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/25.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import UIKit
import AVFoundation

class DeviceUtils {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.width
    
    static func isNotchDevice() -> Bool {
        guard #available(iOS 11.0, *), let window = UIApplication.shared.delegate?.window else {
            return false
        }
        return window?.safeAreaInsets.bottom != 0
    }
    
    /// 获取以分数形式显示的曝光时间
    ///
    /// - Parameter exposureDuration: 曝光时间CMTime
    /// - Returns: 分数形式的曝光时间
    static func getExposureDurationShowValue(_ exposureDuration: CMTime) -> String {
        let value = Float(exposureDuration.value)
        let scale = Float(exposureDuration.timescale)
        //取四舍五入整数位
        let time = lroundf(scale / value)
        if time >= 2 {
            return "1/\(time)"
        } else {
            return "\(1 / time)"
        }
    }
}
