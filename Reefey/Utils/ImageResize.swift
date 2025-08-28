//
//  ImageResize.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//
import Foundation
import SwiftUI
import os.log


struct ImageResize {
    static func resize(imageData: Data, maxDimension: CGFloat = 800) -> Data {
        // Check data size to prevent excessive memory usage
        let maxDataSize = 50 * 1024 * 1024 // 50MB limit
        guard imageData.count < maxDataSize else {
            logEvent("Image data too large: \(imageData.count) bytes", OSLog.storage)
            return imageData
        }
        
        // Convert data to UIImage with autoreleasepool for memory management
        var resizedData: Data = imageData
        
        autoreleasepool {
            guard let uiImage = UIImage(data: imageData) else {
                logEvent("Failed to create UIImage from data", OSLog.storage)
                return // resizedData remains original
            }
            
            // Calculate new size while maintaining aspect ratio
            let originalSize = uiImage.size
            let newSize: CGSize
            
            // Early return if image is already small enough
            guard max(originalSize.width, originalSize.height) > maxDimension else {
                // Still compress if needed
                if let compressedData = uiImage.jpegData(compressionQuality: 0.7) {
                    resizedData = compressedData
                }
                return
            }
            
            if originalSize.width > originalSize.height {
                let ratio = maxDimension / originalSize.width
                newSize = CGSize(width: maxDimension, height: originalSize.height * ratio)
            } else {
                let ratio = maxDimension / originalSize.height
                newSize = CGSize(width: originalSize.width * ratio, height: maxDimension)
            }
            
            // Use UIGraphicsImageRenderer for better memory management (iOS 10+)
            let renderer = UIGraphicsImageRenderer(size: newSize)
            let resizedImage = renderer.image { _ in
                uiImage.draw(in: CGRect(origin: .zero, size: newSize))
            }
            
            // Convert to compressed JPEG data
            if let compressedData = resizedImage.jpegData(compressionQuality: 0.7) {
                resizedData = compressedData
                logEvent("Image resized from \(imageData.count) to \(compressedData.count) bytes", OSLog.storage)
            } else {
                logEvent("Failed to compress resized image", OSLog.storage)
            }
        }
        
        return resizedData
    }
}
