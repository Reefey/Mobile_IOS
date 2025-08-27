//
//  DeviceManager.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//

import Foundation
import UIKit

class DeviceManager {
    static let shared = DeviceManager()
    
    private init() {}
    
    /// Gets the persistent device identifier, creating one if it doesn't exist
    var deviceId: String {
        let key = "static_device_id"
        if let existingId = UserDefaults.standard.string(forKey: key) {
            return existingId
        } else {
            let newId = UIDevice.current.identifierForVendor?.uuidString ?? "default-device-id"
            UserDefaults.standard.set(newId, forKey: key)
            return newId
        }
    }
    
    /// Device model information
    var deviceModel: String {
        return UIDevice.current.model
    }
    
    /// Device name (user-assigned name)
    var deviceName: String {
        return UIDevice.current.name
    }
    
    /// iOS version
    var systemVersion: String {
        return UIDevice.current.systemVersion
    }
    
    /// App version
    var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    /// App build number
    var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}