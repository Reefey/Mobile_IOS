//
//  UnidentifiedImageDetailView.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//

import SwiftUI
import Photos
import SwiftData

struct UnidentifiedImageDetailView: View {
    let imageModel: UnidentifiedImageModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var uiImage: UIImage?
    @State private var isLoading = true
    @State private var isIdentifying = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var successMessage = ""
    
    private let networkService = NetworkService.shared
    private let deviceManager = DeviceManager.shared
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom header
                customHeaderView
                
                // Image display
                imageDisplayView
                
                // Failure information
                if !imageModel.isProcessed {
                    failureInfoView
                }
                
                // Action buttons
                actionButtonsView
            }
        }
        .onAppear {
            loadImage()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK") { }
        } message: {
            Text(successMessage)
        }
    }
    
    private var customHeaderView: some View {
        HStack {
            Button("Close") {
                dismiss()
            }
            .foregroundColor(.teal)
            
            Spacer()
            
            Text("Image Details")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            // Empty view for balance
            Color.clear
                .frame(width: 60)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
    
    private var imageDisplayView: some View {
        GeometryReader { geometry in
            VStack {
                if isLoading {
                    ProgressView("Loading image...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let uiImage = uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Image not available")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height * 0.7)
        }
    }
    
    private var failureInfoView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Identification Failed")
                    .font(.headline)
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                if let failureReason = imageModel.failureReason {
                    HStack {
                        Text("Reason:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(failureReason)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
                
                HStack {
                    Text("Retry Count:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(imageModel.retryCount)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(imageModel.retryCount > 0 ? .red : .primary)
                }
                
                if let lastAttempt = imageModel.lastAttemptDate {
                    HStack {
                        Text("Last Attempt:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(lastAttempt, style: .time)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 16) {
            // Image info
            VStack(alignment: .leading, spacing: 8) {
                Text("Date Taken:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(imageModel.dateTaken, style: .date)
                    .font(.headline)
                
                Text(imageModel.dateTaken, style: .time)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Status:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: imageModel.isProcessed ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(imageModel.isProcessed ? .green : .gray)
                        
                        Text(imageModel.isProcessed ? "Identified" : "Not Identified")
                            .font(.subheadline)
                            .foregroundColor(imageModel.isProcessed ? .green : .gray)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Divider()
            
            // Action buttons
            VStack(spacing: 12) {
                Button(action: {
                    Task {
                        await identifyImage()
                    }
                }) {
                    HStack {
                        if isIdentifying {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "magnifyingglass")
                        }
                        
                        Text(isIdentifying ? "Identifying..." : "Identify Image")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(imageModel.isProcessed ? Color.gray : Color.teal)
                    .cornerRadius(12)
                }
                .disabled(imageModel.isProcessed || isIdentifying)
                
                Button(action: {
                    // Share image
                    shareImage()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Image")
                    }
                    .font(.headline)
                    .foregroundColor(.teal)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.teal.opacity(0.1))
                    .cornerRadius(12)
                }
                .disabled(uiImage == nil)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.top, 20)
    }
    
    private func loadImage() {
        let fetchOptions = PHFetchOptions()
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [imageModel.photoAssetIdentifier], options: fetchOptions)
        
        guard let asset = assets.firstObject else {
            isLoading = false
            return
        }
        
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        
        let targetSize = PHImageManagerMaximumSize
        
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: requestOptions) { image, _ in
            DispatchQueue.main.async {
                self.uiImage = image
                self.isLoading = false
            }
        }
    }
    
    private func identifyImage() async {
        await MainActor.run {
            isIdentifying = true
        }
        
        do {
            guard let imageData = await getImageData() else {
                throw NetworkError.custom("Could not load image data")
            }
            
            let base64String = imageData.base64EncodedString().asJPGBaseURLString()
            let response = try await networkService.analyzePhoto(
                deviceId: deviceManager.deviceId,
                photo: base64String
            )
            
            if response.success, let data = response.data,
               !data.collectionEntries.isEmpty {
                // Successfully identified
                await MainActor.run {
                    imageModel.isProcessed = true
                    try? modelContext.save()
                    successMessage = "Image successfully identified!"
                    showSuccess = true
                }
            } else {
                throw NetworkError.custom("No species identified")
            }
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
        
        await MainActor.run {
            isIdentifying = false
        }
    }
    
    private func getImageData() async -> Data? {
        return await withCheckedContinuation { continuation in
            let fetchOptions = PHFetchOptions()
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: [imageModel.photoAssetIdentifier], options: fetchOptions)
            
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
    
    private func shareImage() {
        guard let uiImage = uiImage else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [uiImage],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

#Preview {
    UnidentifiedImageDetailView(
        imageModel: UnidentifiedImageModel(
            photoAssetIdentifier: "test",
            dateTaken: Date(),
            isProcessed: false
        )
    )
}
