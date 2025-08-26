//
//  ImageResize.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//
import Foundation
import SwiftUI


struct ImageResize {
    static func resize(imageData: Data, maxDimension: CGFloat = 800) -> Data {
        // Convert data to UIImage
        guard let uiImage = UIImage(data: imageData) else {
            return imageData // Return original if conversion fails
        }
        
        // Calculate new size while maintaining aspect ratio
        let originalSize = uiImage.size
        var newSize: CGSize
        
        if originalSize.width > originalSize.height {
            let ratio = maxDimension / originalSize.width
            newSize = CGSize(width: maxDimension, height: originalSize.height * ratio)
        } else {
            let ratio = maxDimension / originalSize.height
            newSize = CGSize(width: originalSize.width * ratio, height: maxDimension)
        }
        
        // Create a new image with the calculated size
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        uiImage.draw(in: CGRect(origin: .zero, size: newSize))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return imageData // Return original if resizing fails
        }
        UIGraphicsEndImageContext()
        
        // Convert to compressed JPEG data
        let compressedData = resizedImage.jpegData(compressionQuality: 0.7) ?? imageData
        
        return compressedData
    }
}
