//
//  CameraManager+ManualOpt.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/4/11.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import AVFoundation

extension CameraManager {
    /// 获取当前设备的最大和最小曝光补偿度
    ///
    /// - Returns: 最大/最小/当前曝光补偿度
    func getDeivceMinMaxEV() -> (min: Float, max: Float, value: Float) {
        guard let device = captureDevice else { return (0, 1, 0.5) }
        if let minEvValue = minEV, let maxEvValue = maxEV {
            return (minEvValue, maxEvValue, device.exposureTargetBias)
        }
        return (device.minExposureTargetBias, device.maxExposureTargetBias, device.exposureTargetBias)
    }
    
    /// 获取当前设备的最大和最小曝光时间
    ///
    /// - Returns: 最大/最小/当前曝光时间，用以显示在UILabel上的最大/最小曝光时间
    func getDeivceMinMaxEt() -> (min: Float, max: Float, minLabel: String, maxLabel: String, value: Float) {
        guard let device = captureDevice else { return (0, 1, "0", "1", 0.5) }
        //用以显示的UILabel上的曝光时间的分母
        let currentExposureDuration = device.exposureDuration
        let currentEt = Float(currentExposureDuration.timescale) / Float(currentExposureDuration.value)
        //获取已有的值
        if let minEtValue = minEV, let maxEtValue = maxEV, let minEtForLabelValue = minEtForLabel, let maxEtForLabelValue = maxEtForLabel {
            return (minEtValue, maxEtValue, minEtForLabelValue, maxEtForLabelValue, currentEt)
        }
        //如果没有已存在的值，则去计算
        let minTime = device.activeFormat.minExposureDuration
        let min = CMTimeGetSeconds(minTime)
        let minForLabel = DeviceUtils.getExposureDurationShowValue(minTime)
        
        let maxTime = device.activeFormat.maxExposureDuration
        let max = CMTimeGetSeconds(maxTime)
        let maxForLabel = DeviceUtils.getExposureDurationShowValue(maxTime)
        
        return (Float(min), Float(max), minForLabel, maxForLabel, currentEt)
    }
    
    /// 获取当前设备的最大和最小ISO
    ///
    /// - Returns: 最大/最小/当前ISO
    func getDeivceMinMaxISO() -> (min: Float, max: Float, value: Float) {
        guard let device = captureDevice else { return (0, 1, 0.5) }
        if let minISOValue = minISO, let maxISOValue = maxISO {
            return (minISOValue, maxISOValue, device.iso)
        }
        return (device.activeFormat.minISO, device.activeFormat.maxISO, device.iso)
    }
    
    /// 获取当前设备的最大和最小焦距
    ///
    /// - Returns: 最大/最小/当前焦距
    func getDeivceMinMaxFL() -> (min: Float, max: Float, value: Float) {
        guard let device = captureDevice else { return (0, 1, 0.5) }
        return (0.0, 1.0, device.lensPosition)
    }
    
    /// 设置曝光补偿
    ///
    /// - Parameter ev: 曝光补偿度
    func changeEV(to ev: Float) {
        guard let device = captureDevice else {
            return
        }
        device.changeProperty {
            $0.setExposureTargetBias(ev) { _ in
                self.delegate?.didChangeEvValue(to: ev)
            }
        }
    }
    
    /// 设置ISO
    ///
    /// - Parameter iso: 感光度
    func changeISO(to iso: Float) {
        guard let device = captureDevice else {
            return
        }
        device.changeProperty { $0.setExposureModeCustom(duration: AVCaptureDevice.currentExposureDuration, iso: iso, completionHandler: { (_) in
            self.delegate?.didChangeISOValue(to: iso)
        })}
    }
    
    /// 设置曝光时间
    ///
    /// - Parameter duration: 曝光时间
    func changeExposureDuration(to duration: Double) {
        guard let device = captureDevice else {
            return
        }
        let durationValue = CMTimeMakeWithSeconds(duration, preferredTimescale: 1000000)
        device.changeProperty { $0.setExposureModeCustom(duration: durationValue, iso: AVCaptureDevice.currentISO, completionHandler: { (_) in
            self.delegate?.didChangeEtValue(to: durationValue)
        })}
    }
    
    /// 设置镜头焦距
    ///
    /// - Parameter lens: 对焦焦距
    func changeFocusLens(to lens: Float) {
        guard let device = captureDevice else {
            return
        }
        device.changeProperty {
            $0.setFocusModeLocked(lensPosition: lens) { _ in
                self.delegate?.didChangeFLValue(to: lens)
            }
        }
    }
}