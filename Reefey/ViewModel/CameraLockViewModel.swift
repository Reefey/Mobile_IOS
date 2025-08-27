//
//  CameraLockViewModel.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//

import Foundation
import AVFoundation
import UIKit
import SwiftUI
import Photos
import SwiftData
import os.log

@Observable
final class CameraLockViewModel: BaseCameraViewModel, @unchecked Sendable {
    
    // Callback for saving to SwiftData
    var onPhotoCapture: ((String) -> Void)?
    
    func saveToPhotos(image: UIImage, completion: @escaping (String?) -> Void) {
        var assetIdentifier: String?
        
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetCreationRequest.creationRequestForAsset(from: image)
            assetIdentifier = creationRequest.placeholderForCreatedAsset?.localIdentifier
        }) { success, error in
            DispatchQueue.main.async {
                if success, let identifier = assetIdentifier {
                    logEvent("Photo saved successfully with identifier: \(identifier)", OSLog.storage)
                    completion(identifier)
                } else {
                    logEvent("Error saving photo: \(error?.localizedDescription ?? "Unknown error")", OSLog.storage)
                    completion(nil)
                }
            }
        }
    }
    
    func saveToSwiftData(photoAssetIdentifier: String, context: ModelContext) {
        // Check if an UnidentifiedImageModel with this photoAssetIdentifier already exists
        let descriptor = FetchDescriptor<UnidentifiedImageModel>(
            predicate: #Predicate { $0.photoAssetIdentifier == photoAssetIdentifier }
        )
        
        do {
            let existingImages = try context.fetch(descriptor)
            
            if existingImages.isEmpty {
                // Create a new UnidentifiedImageModel object and save to SwiftData
                let unidentifiedImage = UnidentifiedImageModel(
                    photoAssetIdentifier: photoAssetIdentifier,
                    dateTaken: Date()
                )
                
                context.insert(unidentifiedImage)
                try context.save()
                logEvent("Photo reference saved to SwiftData successfully", OSLog.storage)
            } else {
                logEvent("Photo with identifier \(photoAssetIdentifier) already exists in SwiftData, skipping duplicate", OSLog.storage)
            }
        } catch {
            logEvent("Error checking/saving to SwiftData: \(error)", OSLog.storage)
        }
    }
    
    // Override template method to handle photo capture for SwiftData storage
    override func handlePhotoCapture(image: UIImage, imageData: Data, resizedImage: Data, existingAssetIdentifier: String? = nil) {
        // Use existing identifier or save to Photos and get identifier for SwiftData
        if let existingIdentifier = existingAssetIdentifier {
            // Gallery image - use existing asset identifier
            onPhotoCapture?(existingIdentifier)
        } else {
            // Camera image - save to Photos first then get identifier
            saveToPhotos(image: image) { [weak self] assetIdentifier in
                if let identifier = assetIdentifier {
                    self?.onPhotoCapture?(identifier)
                }
            }
        }
    }
}

