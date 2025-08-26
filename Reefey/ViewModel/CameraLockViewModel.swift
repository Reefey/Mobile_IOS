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

@Observable
final class CameraLockViewModel: BaseCameraViewModel {
    
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
                    print("Photo saved successfully with identifier: \(identifier)")
                    completion(identifier)
                } else {
                    print("Error saving photo: \(error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                }
            }
        }
    }
    
    func saveToSwiftData(photoAssetIdentifier: String, context: ModelContext) {
        // Create a new UnidentifiedImageModel object and save to SwiftData
        let unidentifiedImage = UnidentifiedImageModel(
            photoAssetIdentifier: photoAssetIdentifier,
            dateTaken: Date()
        )
        
        context.insert(unidentifiedImage)
        
        do {
            try context.save()
            print("Photo reference saved to SwiftData successfully")
        } catch {
            print("Error saving to SwiftData: \(error)")
        }
    }
    
    // Override template method to handle photo capture for SwiftData storage
    override func handlePhotoCapture(image: UIImage, imageData: Data, resizedImage: Data) {
        // Auto-save to Photos and get identifier for SwiftData
        saveToPhotos(image: image) { [weak self] assetIdentifier in
            if let identifier = assetIdentifier {
                self?.onPhotoCapture?(identifier)
            }
        }
    }
}