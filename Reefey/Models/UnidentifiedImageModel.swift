//
//  UnidentifiedImageModel.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//


import SwiftData
import Foundation

// MARK: - SwiftData Models
@Model
class UnidentifiedImageModel {
    var photoAssetIdentifier: String  // PHAsset local identifier
    var dateTaken: Date
    var isProcessed: Bool
    var failureReason: String?  // Reason for failure (network, rate limit, unidentified, etc.)
    var retryCount: Int  // Number of retry attempts
    var lastAttemptDate: Date?  // Last attempt date
    var imageData: Data?  // Optional: store resized image data for retry
    
    init(photoAssetIdentifier: String, dateTaken: Date, failureReason: String? = nil, isProcessed: Bool = false) {
        self.photoAssetIdentifier = photoAssetIdentifier
        self.dateTaken = dateTaken
        self.failureReason = failureReason
        self.isProcessed = isProcessed
        self.retryCount = 0
        self.lastAttemptDate = nil
        self.imageData = nil
    }
    
    // Helper method to update retry information
    func updateRetryInfo(failureReason: String) {
        self.retryCount += 1
        self.lastAttemptDate = Date()
        self.failureReason = failureReason
        self.isProcessed = false
    }
    
    // Helper method to mark as successfully processed
    func markAsProcessed() {
        self.isProcessed = true
        self.failureReason = nil
    }
}
