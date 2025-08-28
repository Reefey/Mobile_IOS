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
    
    // MARK: - Task Management
    private var currentAnalysisTask: Task<Void, Never>?
    private var currentTaskId: String?
    
    deinit {
        cancelCurrentAnalysis()
    }
    
    // MARK: - Public Methods
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
    
    func analyzeImage(_ imageModel: UnidentifiedImageModel, modelContext: ModelContext, onSuccess: @escaping (Int) -> Void = { _ in }) async {
        // Cancel any existing analysis
        cancelCurrentAnalysis()
        
        await MainActor.run {
            isAnalyzing = true
            errorMessage = nil
        }
        
        currentAnalysisTask = Task {
            do {
                try Task.checkCancellation()
                
                // Get PNG data from PHAsset with timeout
                let pngData = try await withTimeout(seconds: 30) {
                    await self.getPNGData(from: imageModel.photoAssetIdentifier)
                }
                
                guard let pngData = pngData else {
                    await MainActor.run {
                        errorMessage = "Failed to load image data"
                        isAnalyzing = false
                    }
                    return
                }
                
                try Task.checkCancellation()
                
                // Generate unique task ID
                let taskId = UUID().uuidString
                currentTaskId = taskId
                
                // Send to AI with timeout and cancellation support
                let marineData = try await aiService.sendToAI(pngImage: pngData, taskId: taskId)
                
                try Task.checkCancellation()
                
                await MainActor.run {
                    // Update isProcessed to true
                    imageModel.isProcessed = true
                    do {
                        try modelContext.save()
                        // Call success callback with marine ID
                        onSuccess(marineData.id)
                    } catch {
                        errorMessage = "Failed to save to database: \(error.localizedDescription)"
                    }
                    isAnalyzing = false
                }
            } catch is CancellationError {
                await MainActor.run {
                    isAnalyzing = false
                    // Don't show error for cancellation
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to analyze image: \(error.localizedDescription)"
                    isAnalyzing = false
                }
            }
            
            currentTaskId = nil
        }
        
        await currentAnalysisTask?.value
    }
    
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T?) async throws -> T? {
        return try await withThrowingTaskGroup(of: T?.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw CancellationError()
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
    
    // MARK: - Private Methods
    private func getPNGData(from assetIdentifier: String) async -> Data? {
        return await withCheckedContinuation { continuation in
            autoreleasepool {
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
                requestOptions.resizeMode = .exact
                
                // Request image data directly to avoid additional processing
                imageManager.requestImageDataAndOrientation(for: asset, options: requestOptions) { data, _, _, _ in
                    guard let imageData = data else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    // Use ImageResize utility for consistent processing and memory management
                    let processedData = ImageResize.resize(imageData: imageData, maxDimension: 800)
                    continuation.resume(returning: processedData)
                }
            }
        }
    }
}
