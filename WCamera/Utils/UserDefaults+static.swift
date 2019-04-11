//
//  UserDefaults+static.swift
//  WCamera
//
//  Created by HalseyW-15 on 2019/3/21.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//
//  extension String {
//      static let ID = "id"
//  }
import Foundation

extension UserDefaults {
    static func saveInt(_ value: Int, forKey: String) {
        UserDefaults.standard.set(value, forKey: forKey)
    }
    
    static func saveString(_ value: String, forKey: String) {
        UserDefaults.standard.set(value, forKey: forKey)
    }
    
    static func saveBool(_ value: Bool, forKey: String) {
        UserDefaults.standard.set(value, forKey: forKey)
    }
    
    static func saveFloat(_ value: Float, forKey: String) {
        UserDefaults.standard.set(value, forKey: forKey)
    }
    
    static func saveDouble(_ value: Any, forKey: String) {
        UserDefaults.standard.set(value, forKey: forKey)
    }
    
    static func getInt(forKey: String) -> Int {
        return UserDefaults.standard.integer(forKey: forKey)
    }
    
    static func getString(forKey: String) -> String? {
        return UserDefaults.standard.string(forKey: forKey)
    }
    
    static func getBool(forKey: String) -> Bool {
        return UserDefaults.standard.bool(forKey: forKey)
    }
    
    static func getFloat(forKey: String) -> Float {
        return UserDefaults.standard.float(forKey: forKey)
    }
    
    static func getDouble(forKey: String) -> Double {
        return UserDefaults.standard.double(forKey: forKey)
    }
    
    static func remove(forKey: String) {
        UserDefaults.standard.removeObject(forKey: forKey)
    }
}

extension String {
    //0：广角，1：长焦
    static let DualCameraType = "DualCameraType"
    //0：关闭，1：开启，2：自动
    static let FlashMode = "FlashMode"
}
