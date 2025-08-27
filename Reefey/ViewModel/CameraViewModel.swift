//
//  CameraViewModel.swift
//  Reefey
//
//  Created by Reza Juliandri on 15/08/25.
//

import Foundation
import AVFoundation
import UIKit
import SwiftUI
import Photos

@Observable
final class CameraViewModel: BaseCameraViewModel {
    private let networkService = NetworkService.shared
    private let deviceManager = DeviceManager.shared
    
    // Callback for saving to SwiftData when AI fails
    var onAIFailure: ((String) -> Void)?
    
    // Callback for hiding the identify dialog
    var onAIProcessingComplete: (() -> Void)?
    
    // Callback for successful identification with marine data and captured image
    var onAIIdentificationSuccess: ((MarineData, UIImage) -> Void)?
    
    // Callback for showing unidentified dialog when AI fails
    var onAIUnidentified: (() -> Void)?
    
    // Callback for showing offline dialog when network is unavailable
    var onNetworkUnavailable: (() -> Void)?
    
    // Callback for showing rate limit dialog when AI limit is reached
    var onRateLimitExceeded: (() -> Void)?
    
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
    
    // Note: SwiftData functionality removed - failed attempts are now handled by direct Photos library access
    
    func sendToAI(pngImage: Data) async throws -> MarineData {
        print("Sending binary image data...")
        print("Making network request with deviceId: \(deviceManager.deviceId)...")
        let base64String = pngImage.base64EncodedString().asJPGBaseURLString()
        let response = try await networkService.analyzePhoto(deviceId: deviceManager.deviceId, photo: base64String)
        
        if response.success {
            print("AI Response: \(response.data)")
            print("Message: \(response.message ?? "No message")")
            
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
            print("AI Analysis failed: \(response.error ?? "Unknown error")")
            throw NetworkError.custom(response.error ?? "AI analysis failed")
        }
    }
    
    // Override template method to handle photo capture for direct AI analysis
    override func handlePhotoCapture(image: UIImage, imageData: Data, resizedImage: Data) {
        // Auto-save to Photos and get identifier
        saveToPhotos(image: image) { [weak self] assetIdentifier in
            guard let self = self, let identifier = assetIdentifier else { return }
            
            // Send to AI (async call)
            Task {
                do {
                    let marineData = try await self.sendToAI(pngImage: resizedImage)
                    print("AI analysis successful")
                    await MainActor.run {
                        self.onAIIdentificationSuccess?(marineData, image)
                    }
                } catch {
                    print("Error sending to AI: \(error)")
                    
                    // Handle different types of errors and show appropriate dialogs
                    await MainActor.run {
                        if let networkError = error as? NetworkError {
                            print("NetworkError detected: \(networkError)")
                            switch networkError {
                            case .custom(let message) where message.contains("Rate limit exceeded") || message.contains("RATE_LIMIT_EXCEEDED"):
                                // Rate limit exceeded - show rate limit dialog
                                print("Rate limit detected with message: \(message)")
                                self.onAIFailure?(identifier)
                                self.onRateLimitExceeded?()
                            case .httpError(let statusCode) where statusCode == 429:
                                // Rate limit exceeded (HTTP 429) - show rate limit dialog
                                print("HTTP 429 Rate limit detected")
                                self.onAIFailure?(identifier)
                                self.onRateLimitExceeded?()
                            case .invalidURL, .invalidResponse, .httpError, .noData:
                                // Network connectivity issues - show offline dialog
                                self.onAIFailure?(identifier)
                                self.onNetworkUnavailable?()
                            case .decodingError, .custom:
                                // AI processing issues - show unidentified dialog
                                self.onAIFailure?(identifier)
                                self.onAIUnidentified?()
                            }
                        } else if (error as NSError).domain == NSURLErrorDomain {
                            // URL loading system errors (network issues)
                            self.onAIFailure?(identifier)
                            self.onNetworkUnavailable?()
                        } else {
                            // Other errors - treat as unidentified
                            self.onAIFailure?(identifier)
                            self.onAIUnidentified?()
                        }
                    }
                }
            }
        }
    }
}
