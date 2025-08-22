//
//  Logger.swift
//  AppExperiment
//
//  Created by Reza Juliandri on 22/08/25.
//


import Foundation
import os.log

extension OSLog {
    private static let subsystem = "com.blublub.AppExperiment"
    private static let category = "volume_session"
    static let audioSession = OSLog(subsystem: OSLog.subsystem, category: OSLog.category)
}

/// Write a message to system log.
func logEvent(_ message: String, _ category: OSLog) {
    os_log("%{public}@", log: category, type: .info, message)
}
