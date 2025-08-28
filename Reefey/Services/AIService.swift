//
//  AIService.swift
//  Reefey
//
//  Created by Reza Juliandri on 28/08/25.
//

import SwiftUI
import Foundation
import os

class AIService {
    static let shared = AIService()
    
    private init() {}
    private let deviceManager = DeviceManager.shared
    private let networkService = NetworkService.shared
    
    func sendToAI(pngImage: Data) async throws -> MarineData {
        logEvent("Sending binary image data...", OSLog.ai)
        logEvent("Making network request with deviceId: \(deviceManager.deviceId)...", OSLog.networking)
        let base64String = pngImage.base64EncodedString().asJPGBaseURLString()
        let response = try await networkService.analyzePhoto(deviceId: deviceManager.deviceId, photo: base64String)
        
        if response.success {
            logEvent("AI Response: \(response.data.debugDescription)", OSLog.ai)
            logEvent("Message: \(response.message ?? "No message")", OSLog.ai)
            
            // Check if we have identified species with marine data
            if let data = response.data,
               !data.collectionEntries.isEmpty,
               let marineData = data.collectionEntries.first?.marineData {
                // Species identified successfully
                return marineData
            } else {
                // No species identified
                throw NetworkError.custom("No species identified")
            }
        } else {
            logEvent("AI Analysis failed: \(response.error ?? "Unknown error")", OSLog.ai)
            throw NetworkError.custom(response.error ?? "AI analysis failed")
        }
    }
}
