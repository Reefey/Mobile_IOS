//
//  UnidentifiedImagesViewModel.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//

import Foundation
import SwiftUI
import SwiftData
import Photos
import UIKit

@Observable
class UnidentifiedImagesViewModel {
    private let networkService = NetworkService.shared
    private let deviceManager = DeviceManager.shared
    
    var unidentifiedImages: [UnidentifiedImageModel] = []
    var selectedImages: Set<String> = []
    var isSelecting = false
    var isProcessing = false
    var processingProgress: Double = 0.0
    var showError = false
    var errorMessage = ""
    var showSuccess = false
    var successMessage = ""
    
    // Callback for successful identification
    var onIdentificationSuccess: (([BatchIdentifyResult]) -> Void)?
    
    // Callback for navigation to collections
    var onNavigateToCollections: (() -> Void)?
    
    func loadUnidentifiedImages(context: ModelContext) {
        let descriptor = FetchDescriptor<UnidentifiedImageModel>(
            sortBy: [SortDescriptor(\.dateTaken, order: .reverse)]
        )
        
        do {
            unidentifiedImages = try context.fetch(descriptor)
        } catch {
            print("Error fetching unidentified images: \(error)")
        }
    }
    
    func toggleSelection(for assetIdentifier: String) {
        if selectedImages.contains(assetIdentifier) {
            selectedImages.remove(assetIdentifier)
        } else {
            selectedImages.insert(assetIdentifier)
        }
    }
    
    func selectAll() {
        selectedImages = Set(unidentifiedImages.map { $0.photoAssetIdentifier })
    }
    
    func deselectAll() {
        selectedImages.removeAll()
    }
    
    func toggleSelectMode() {
        isSelecting.toggle()
        if !isSelecting {
            selectedImages.removeAll()
        }
    }
    
    func deleteSelectedImages(context: ModelContext) {
        let imagesToDelete = unidentifiedImages.filter { selectedImages.contains($0.photoAssetIdentifier) }
        
        for image in imagesToDelete {
            context.delete(image)
        }
        
        do {
            try context.save()
            unidentifiedImages.removeAll { selectedImages.contains($0.photoAssetIdentifier) }
            selectedImages.removeAll()
            isSelecting = false
        } catch {
            print("Error deleting images: \(error)")
            errorMessage = "Failed to delete images"
            showError = true
        }
    }
    
    func batchIdentify(context: ModelContext) async {
        guard !selectedImages.isEmpty else { return }
        
        await MainActor.run {
            isProcessing = true
            processingProgress = 0.0
        }
        
        do {
            // Get selected image models
            let selectedImageModels = unidentifiedImages.filter { selectedImages.contains($0.photoAssetIdentifier) }
            
            // Convert images to base64
            var base64Images: [String] = []
            
            let totalCount = selectedImageModels.count
            for (index, imageModel) in selectedImageModels.enumerated() {
                if let imageData = await getImageData(for: imageModel.photoAssetIdentifier) {
                    let base64String = imageData.base64EncodedString().asJPGBaseURLString()
                    base64Images.append(base64String)
                }
                await MainActor.run {
                    processingProgress = Double(index + 1) / Double(totalCount) * 0.5
                }
            }
            
            guard !base64Images.isEmpty else {
                throw NetworkError.custom("No valid images found")
            }
            
            // Call batch identify API
            await MainActor.run {
                processingProgress = 0.5
            }
            
            let response = try await networkService.batchIdentify(
                deviceId: deviceManager.deviceId,
                photos: base64Images
            )
            
            await MainActor.run {
                processingProgress = 1.0
            }
            
            if response.success, let data = response.data {
                // Update processed status for successful identifications
                for result in data.results where result.success {
                    if let imageModel = unidentifiedImages.first(where: { $0.photoAssetIdentifier == result.photoAssetIdentifier }) {
                        imageModel.isProcessed = true
                    }
                }
                
                try context.save()
                
                await MainActor.run {
                    successMessage = "Successfully identified \(data.successfulIdentifications) out of \(data.totalProcessed) images"
                    showSuccess = true
                    onIdentificationSuccess?(data.results)
                    
                    // If all images were successfully identified, offer to navigate to collections
                    if data.successfulIdentifications == data.totalProcessed && data.successfulIdentifications > 0 {
                        onNavigateToCollections?()
                    }
                }
            } else {
                throw NetworkError.custom(response.error ?? "Batch identification failed")
            }
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
        
        await MainActor.run {
            isProcessing = false
            processingProgress = 0.0
        }
    }
    
    private func getImageData(for assetIdentifier: String) async -> Data? {
        return await withCheckedContinuation { continuation in
            let fetchOptions = PHFetchOptions()
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: fetchOptions)
            
            guard let asset = assets.firstObject else {
                continuation.resume(returning: nil)
                return
            }
            
            let imageManager = PHImageManager.default()
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = false
            requestOptions.deliveryMode = .highQualityFormat
            
            imageManager.requestImageDataAndOrientation(for: asset, options: requestOptions) { data, _, _, _ in
                continuation.resume(returning: data)
            }
        }
    }
}
