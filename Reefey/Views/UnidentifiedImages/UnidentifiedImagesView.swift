//
//  UnidentifiedImagesView.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//

import SwiftUI
import Photos

struct UnidentifiedImagesView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var path: [NavigationPath]
    @State private var unidentifiedImages: [PhotoItem] = []
    @State private var selectedImages: Set<String> = []
    @State private var isSelecting = false
    @State private var isLoading = true
    @State private var selectedImageForDetail: PhotoItem?
    @State private var showingImageDetail = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var successMessage = ""
    @State private var isProcessing = false
    @State private var processingProgress: Double = 0.0
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content - fill remaining space
                if unidentifiedImages.isEmpty && !isLoading {
                    emptyStateView
                } else {
                    galleryGridView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarHidden(true)
        .onAppear {
            loadUnidentifiedImages()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("View Collections") {
                // Navigate to collections
                dismiss()
                path.removeAll()
            }
            Button("Continue") { }
        } message: {
            Text(successMessage)
        }
        .sheet(isPresented: $showingImageDetail) {
            if let selectedImage = selectedImageForDetail {
                UnidentifiedImageDetailView(photoItem: selectedImage)
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 0) {
            // Status bar spacer
            Rectangle()
                .fill(Color.clear)
                .frame(height: 44)
            
            // Header content
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text("To be Identified")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: {
                        // Navigate to collections
                        dismiss()
                        // Clear navigation path to go back to collections
                        path.removeAll()
                    }) {
                        Image(systemName: "photo.stack")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        toggleSelectMode()
                    }) {
                        Text(isSelecting ? "Cancel" : "Select")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(20)
                    }
                    
                    if !unidentifiedImages.isEmpty {
                        Button(action: {
                            clearAllImages()
                        }) {
                            Text("Clear All")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(20)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            // Selection toolbar
            if isSelecting {
                selectionToolbar
            }
        }
    }
    
    private var selectionToolbar: some View {
        HStack {
            Text("\(selectedImages.count) selected")
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            if !selectedImages.isEmpty {
                Button("Delete") {
                    deleteSelectedImages()
                }
                .foregroundColor(.red)
                .font(.subheadline)
                .fontWeight(.medium)
                
                Button("Identify") {
                    Task {
                        await batchIdentify()
                    }
                }
                .foregroundColor(.green)
                .font(.subheadline)
                .fontWeight(.medium)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.8))
    }
    
    private var emptyStateView: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "photo.stack")
                    .font(.system(size: 80))
                    .foregroundColor(.gray.opacity(0.6))
                
                Text("No Unidentified Images")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Take photos when offline or when AI fails to see them here for batch identification.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    private var galleryGridView: some View {
        ScrollView {
            if isProcessing {
                VStack(spacing: 20) {
                    ProgressView(value: processingProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding(.horizontal, 20)
                    
                    Text("Processing \(Int(processingProgress * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
            }
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(unidentifiedImages, id: \.assetIdentifier) { photoItem in
                    UnidentifiedImageGridItem(
                        photoItem: photoItem,
                        isSelected: selectedImages.contains(photoItem.assetIdentifier),
                        isSelecting: isSelecting
                    ) {
                        if isSelecting {
                            toggleSelection(for: photoItem.assetIdentifier)
                        } else {
                            selectedImageForDetail = photoItem
                            showingImageDetail = true
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadUnidentifiedImages() {
        isLoading = true
        
        // Request photo library access
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                if status == .authorized {
                    fetchUnidentifiedImages()
                } else {
                    errorMessage = "Photo library access is required"
                    showError = true
                }
                isLoading = false
            }
        }
    }
    
    private func fetchUnidentifiedImages() {
        // For now, we'll fetch recent photos as a placeholder
        // In a real implementation, you'd filter for specific criteria
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 50 // Limit to recent photos
        
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        var photoItems: [PhotoItem] = []
        
        assets.enumerateObjects { asset, index, stop in
            let photoItem = PhotoItem(
                assetIdentifier: asset.localIdentifier,
                dateTaken: asset.creationDate ?? Date(),
                failureReason: "Sample failure reason",
                retryCount: 0,
                lastAttemptDate: nil
            )
            photoItems.append(photoItem)
        }
        
        DispatchQueue.main.async {
            self.unidentifiedImages = photoItems
        }
    }
    
    private func toggleSelectMode() {
        isSelecting.toggle()
        if !isSelecting {
            selectedImages.removeAll()
        }
    }
    
    private func toggleSelection(for assetIdentifier: String) {
        if selectedImages.contains(assetIdentifier) {
            selectedImages.remove(assetIdentifier)
        } else {
            selectedImages.insert(assetIdentifier)
        }
    }
    
    private func deleteSelectedImages() {
        unidentifiedImages.removeAll { selectedImages.contains($0.assetIdentifier) }
        selectedImages.removeAll()
        isSelecting = false
    }
    
    private func clearAllImages() {
        unidentifiedImages.removeAll()
        selectedImages.removeAll()
        isSelecting = false
    }
    
    private func batchIdentify() async {
        guard !selectedImages.isEmpty else { return }
        
        await MainActor.run {
            isProcessing = true
            processingProgress = 0.0
        }
        
        // Simulate batch processing
        let totalCount = selectedImages.count
        for (index, _) in selectedImages.enumerated() {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
            await MainActor.run {
                processingProgress = Double(index + 1) / Double(totalCount)
            }
        }
        
        await MainActor.run {
            isProcessing = false
            processingProgress = 0.0
            successMessage = "Successfully processed \(totalCount) images"
            showSuccess = true
            selectedImages.removeAll()
            isSelecting = false
        }
    }
}

// MARK: - PhotoItem Model

struct PhotoItem {
    let assetIdentifier: String
    let dateTaken: Date
    let failureReason: String
    let retryCount: Int
    let lastAttemptDate: Date?
}

// MARK: - UnidentifiedImageGridItem

struct UnidentifiedImageGridItem: View {
    let photoItem: PhotoItem
    let isSelected: Bool
    let isSelecting: Bool
    let onTap: () -> Void
    
    @State private var uiImage: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Image
                Group {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    } else if let uiImage = uiImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                            .cornerRadius(12)
                    } else {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                
                // Selection overlay
                if isSelecting {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isSelected ? .blue : .white)
                                .font(.title2)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(8)
                }
                
                // Failure indicator
                if !isSelecting {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .padding(8)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        let fetchOptions = PHFetchOptions()
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [photoItem.assetIdentifier], options: fetchOptions)
        
        guard let asset = assets.firstObject else {
            isLoading = false
            return
        }
        
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: requestOptions) { image, _ in
            DispatchQueue.main.async {
                self.uiImage = image
                self.isLoading = false
            }
        }
    }
}

// MARK: - UnidentifiedImageDetailView

struct UnidentifiedImageDetailView: View {
    let photoItem: PhotoItem
    @Environment(\.dismiss) private var dismiss
    @State private var uiImage: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let uiImage = uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                        .font(.system(size: 100))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Failure info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Failure Reason: \(photoItem.failureReason)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Retry Count: \(photoItem.retryCount)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let lastAttempt = photoItem.lastAttemptDate {
                        Text("Last Attempt: \(lastAttempt, style: .date)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding()
                
                // Action buttons
                HStack(spacing: 20) {
                    Button("Retry") {
                        // Implement retry logic
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Delete") {
                        // Implement delete logic
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
                .padding()
            }
            .navigationTitle("Image Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        let fetchOptions = PHFetchOptions()
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [photoItem.assetIdentifier], options: fetchOptions)
        
        guard let asset = assets.firstObject else {
            isLoading = false
            return
        }
        
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        
        imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions) { image, _ in
            DispatchQueue.main.async {
                self.uiImage = image
                self.isLoading = false
            }
        }
    }
}

#Preview {
    UnidentifiedImagesView(path: .constant([]))
}
