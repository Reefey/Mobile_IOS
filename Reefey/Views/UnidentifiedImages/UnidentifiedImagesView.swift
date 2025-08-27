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
    
    // Custom colors matching Figma design
    private let lightTeal = Color(hex: "E8F4F8")
    private let offWhite = Color(hex: "F8F9FA")
    private let lightGray = Color(hex: "E9ECEF")
    private let darkTeal = Color(hex: "6B9AC4")
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            // Background
            offWhite
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header section with light teal background
                headerView
                
                // Grid section with off-white background
                gridSection
                
                // Identify button at bottom
                identifyButton
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
        ZStack {
            // Light teal background
            lightTeal
                .frame(height: 200)
            
            VStack(spacing: 0) {
                // Status bar spacer
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 44)
                
                // Header content
                HStack {
                    Text("To be Identified")
                        .font(.custom("Georgia", size: 24))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            toggleSelectMode()
                        }) {
                            Text("Select")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(lightGray)
                                .cornerRadius(20)
                        }
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(darkTeal)
                                .frame(width: 32, height: 32)
                                .background(lightGray)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                Spacer()
                
                // Question mark icon in bottom-right
                HStack {
                    Spacer()
                    Image(systemName: "questionmark")
                        .font(.system(size: 60))
                        .foregroundColor(darkTeal)
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                }
            }
        }
    }
    
    private var gridSection: some View {
        VStack {
            if unidentifiedImages.isEmpty && !isLoading {
                emptyStateView
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 1) {
                        ForEach(Array(unidentifiedImages.enumerated()), id: \.element.assetIdentifier) { index, photoItem in
                            UnidentifiedImageGridItem(
                                photoItem: photoItem,
                                isSelected: selectedImages.contains(photoItem.assetIdentifier),
                                isSelecting: isSelecting,
                                badgeNumber: index + 1
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
                    .padding(.top, 20)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(offWhite)
    }
    
    private var identifyButton: some View {
        Button(action: {
            Task {
                await batchIdentify()
            }
        }) {
            Text("Identify")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(lightTeal)
                .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .disabled(selectedImages.isEmpty || isProcessing)
    }
    
    private var emptyStateView: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "photo.stack")
                    .font(.system(size: 80))
                    .foregroundColor(lightGray)
                
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
        fetchOptions.fetchLimit = 9 // Limit to 9 photos for 3x3 grid
        
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
    let badgeNumber: Int
    let onTap: () -> Void
    
    @State private var uiImage: UIImage?
    @State private var isLoading = true
    
    // Custom colors
    private let lightTeal = Color(hex: "E8F4F8")
    private let lightGray = Color(hex: "E9ECEF")
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Image or placeholder
                Group {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(lightGray)
                    } else if let uiImage = uiImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                    } else {
                        Image(systemName: "photo")
                            .foregroundColor(lightGray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(lightGray)
                    }
                }
                
                // Numbered badge overlay
                VStack {
                    HStack {
                        Spacer()
                        Text("\(badgeNumber)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(lightTeal)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(8)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .aspectRatio(1, contentMode: .fit)
        .background(lightGray)
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
