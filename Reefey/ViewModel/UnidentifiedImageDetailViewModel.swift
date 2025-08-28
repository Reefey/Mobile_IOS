import Foundation
import SwiftUI
import SwiftData
import Photos

@Observable
class UnidentifiedImageDetailViewModel {
    private let aiService = AIService.shared
    
    // MARK: - Published Properties
    var isAnalyzing = false
    var errorMessage: String?
    
    // MARK: - Public Methods
    func analyzeImage(_ imageModel: UnidentifiedImageModel, modelContext: ModelContext, onSuccess: @escaping (Int) -> Void = { _ in }) async {
        await MainActor.run {
            isAnalyzing = true
            errorMessage = nil
        }
        
        do {
            // Get PNG data from PHAsset
            if let pngData = await getPNGData(from: imageModel.photoAssetIdentifier) {
                // Send to AI
                let marineData = try await aiService.sendToAI(pngImage: pngData)
                
                await MainActor.run {
                    // Update isProcessed to true
                    imageModel.isProcessed = true
                    try? modelContext.save()
                    // Call success callback with marine ID
                    onSuccess(marineData.id)
                }
            } else {
                await MainActor.run {
                    errorMessage = "Failed to load image data"
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to analyze image: \(error.localizedDescription)"
            }
        }
        
        await MainActor.run {
            isAnalyzing = false
        }
    }
    
    // MARK: - Private Methods
    private func getPNGData(from assetIdentifier: String) async -> Data? {
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
            requestOptions.isNetworkAccessAllowed = true
            
            imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions) { image, _ in
                guard let uiImage = image else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let pngData = uiImage.pngData()
                continuation.resume(returning: pngData)
            }
        }
    }
}