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
import SwiftData
import os.log

@Observable
final class CameraViewModel: BaseCameraViewModel {
    private let networkService = NetworkService.shared
    private let deviceManager = DeviceManager.shared
    private let aiService = AIService.shared
    
    // Current AI analysis task for cancellation
    private var currentAnalysisTask: Task<Void, Never>?
    private var currentTaskId: String?
    
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
    
    deinit {
        cancelCurrentAnalysis()
    }
    
    override func cleanup() {
        cancelCurrentAnalysis()
        // Call parent cleanup to stop camera session
        super.cleanup()
    }
    
    func cancelCurrentAnalysis() {
        currentAnalysisTask?.cancel()
        currentAnalysisTask = nil
        
        if let taskId = currentTaskId {
            Task {
                await aiService.cancelAnalysis(taskId: taskId)
            }
            currentTaskId = nil
        }
    }
    
    func saveToPhotos(image: UIImage) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            var assetIdentifier: String?
            
            PHPhotoLibrary.shared().performChanges({
                let creationRequest = PHAssetCreationRequest.creationRequestForAsset(from: image)
                assetIdentifier = creationRequest.placeholderForCreatedAsset?.localIdentifier
            }) { success, error in
                if success, let identifier = assetIdentifier {
                    logEvent("Photo saved successfully with identifier: \(identifier)", OSLog.storage)
                    continuation.resume(returning: identifier)
                } else {
                    let saveError = error ?? NSError(domain: "PhotoSaveError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to save photo"])
                    logEvent("Error saving photo: \(saveError.localizedDescription)", OSLog.storage)
                    continuation.resume(throwing: saveError)
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
                logEvent("Photo reference saved to SwiftData due to AI failure", OSLog.storage)
            } else {
                logEvent("Photo with identifier \(photoAssetIdentifier) already exists in SwiftData, skipping duplicate", OSLog.storage)
            }
        } catch {
            logEvent("Error checking/saving to SwiftData: \(error)", OSLog.storage)
        }
    }
    
    // Override template method to handle photo capture for direct AI analysis
    override func handlePhotoCapture(image: UIImage, imageData: Data, resizedImage: Data, existingAssetIdentifier: String? = nil) {
        // Cancel any existing analysis
        cancelCurrentAnalysis()
        
        currentAnalysisTask = Task {
            do {
                let assetIdentifier: String
                
                if let existingIdentifier = existingAssetIdentifier {
                    // Gallery image - use existing asset identifier
                    assetIdentifier = existingIdentifier
                } else {
                    // Camera image - save to Photos first then get identifier
                    assetIdentifier = try await saveToPhotos(image: image)
                }
                
                try Task.checkCancellation()
                await processImageWithAI(image: image, resizedImage: resizedImage, assetIdentifier: assetIdentifier)
            } catch is CancellationError {
                logEvent("Photo capture analysis was cancelled", OSLog.ai)
            } catch {
                logEvent("Photo capture failed: \(error)", OSLog.ai)
                await MainActor.run {
                    self.onAIUnidentified?()
                }
            }
        }
    }
    
    private func processImageWithAI(image: UIImage, resizedImage: Data, assetIdentifier: String) async {
        do {
            try Task.checkCancellation()
            
            // Generate unique task ID for this analysis
            let taskId = UUID().uuidString
            currentTaskId = taskId
            
            let marineData = try await aiService.sendToAI(pngImage: resizedImage, taskId: taskId)
            
            try Task.checkCancellation()
            
            logEvent("AI analysis successful", OSLog.ai)
            await MainActor.run {
                self.onAIIdentificationSuccess?(marineData, image)
            }
        } catch is CancellationError {
            logEvent("AI analysis was cancelled", OSLog.ai)
        } catch {
            logEvent("Error sending to AI: \(error)", OSLog.ai)
            
            // Check if it's a network connectivity issue
            if let networkError = error as? NetworkError {
                logEvent("NetworkError detected: \(networkError)", OSLog.networking)
                switch networkError {
                case .custom(let message) where message.contains("Rate limit exceeded") || message.contains("RATE_LIMIT_EXCEEDED"):
                    // Rate limit exceeded - show rate limit dialog
                    logEvent("Rate limit detected with message: \(message)", OSLog.networking)
                    await MainActor.run {
                        self.onAIFailure?(assetIdentifier)
                        self.onRateLimitExceeded?()
                    }
                case .httpError(let statusCode) where statusCode == 429:
                    // Rate limit exceeded (HTTP 429) - show rate limit dialog
                    logEvent("HTTP 429 Rate limit detected", OSLog.networking)
                    await MainActor.run {
                        self.onAIFailure?(assetIdentifier)
                        self.onRateLimitExceeded?()
                    }
                case .invalidURL, .invalidResponse, .httpError, .noData:
                    // Network connectivity issues - show offline dialog
                    await MainActor.run {
                        self.onAIFailure?(assetIdentifier)
                        self.onNetworkUnavailable?()
                    }
                case .decodingError, .custom:
                    // AI processing issues - show unidentified dialog
                    await MainActor.run {
                        self.onAIFailure?(assetIdentifier)
                        self.onAIUnidentified?()
                    }
                }
            } else if (error as NSError).domain == NSURLErrorDomain {
                // URL loading system errors (network issues)
                await MainActor.run {
                    self.onAIFailure?(assetIdentifier)
                    self.onNetworkUnavailable?()
                }
            } else {
                // Other errors - treat as unidentified
                await MainActor.run {
                    self.onAIFailure?(assetIdentifier)
                    self.onAIUnidentified?()
                }
            }
        }
        
        // Clear the current task ID when done
        currentTaskId = nil
    }
}
