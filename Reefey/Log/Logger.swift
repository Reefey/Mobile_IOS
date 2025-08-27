//
//  Logger.swift
//  Reefey
//
//  Created by Reza Juliandri on 22/08/25.
//


import Foundation
import os.log

extension OSLog {
    private static let subsystem = "com.blublub.Reefey"
    
    static let audioSession = OSLog(subsystem: subsystem, category: "volume_session")
    static let camera = OSLog(subsystem: subsystem, category: "camera")
    static let networking = OSLog(subsystem: subsystem, category: "networking")
    static let ai = OSLog(subsystem: subsystem, category: "ai")
    static let storage = OSLog(subsystem: subsystem, category: "storage")
    static let collections = OSLog(subsystem: subsystem, category: "collections")
}

/// Write a message to system log.
func logEvent(_ message: String, _ category: OSLog) {
    os_log("%{public}@", log: category, type: .info, message)
}
