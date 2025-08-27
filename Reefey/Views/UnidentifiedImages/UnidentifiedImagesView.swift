//
//  UnidentifiedImagesView.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//

import SwiftUI
import SwiftData
import Photos

struct UnidentifiedImagesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Binding var path: [NavigationPath]
    @State private var viewModel = UnidentifiedImagesViewModel()
    @State private var selectedImageForDetail: UnidentifiedImageModel?
    @State private var showingImageDetail = false
    
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
                
                // Content
                if viewModel.unidentifiedImages.isEmpty {
                    emptyStateView
                } else {
                    galleryGridView
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadUnidentifiedImages(context: modelContext)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("Success", isPresented: $viewModel.showSuccess) {
            Button("View Collections") {
                // Navigate to collections
                dismiss()
                path.removeAll()
            }
            Button("Continue") { }
        } message: {
            Text(viewModel.successMessage)
        }
        .sheet(isPresented: $showingImageDetail) {
            if let selectedImage = selectedImageForDetail {
                UnidentifiedImageDetailView(imageModel: selectedImage)
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
                        viewModel.toggleSelectMode()
                    }) {
                        Text(viewModel.isSelecting ? "Cancel" : "Select")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.teal, Color.teal.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            // Selection toolbar
            if viewModel.isSelecting {
                selectionToolbar
            }
        }
    }
    
    private var selectionToolbar: some View {
        HStack {
            Button(action: {
                if viewModel.selectedImages.count == viewModel.unidentifiedImages.count {
                    viewModel.deselectAll()
                } else {
                    viewModel.selectAll()
                }
            }) {
                Text(viewModel.selectedImages.count == viewModel.unidentifiedImages.count ? "Deselect All" : "Select All")
                    .font(.subheadline)
                    .foregroundColor(.teal)
            }
            
            Spacer()
            
            Text("\(viewModel.selectedImages.count) selected")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: {
                Task {
                    await viewModel.batchIdentify(context: modelContext)
                }
            }) {
                Text("Identify")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(viewModel.selectedImages.isEmpty ? Color.gray : Color.teal)
                    .cornerRadius(20)
            }
            .disabled(viewModel.selectedImages.isEmpty || viewModel.isProcessing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "photo.stack")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
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
    }
    
    private var galleryGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(viewModel.unidentifiedImages, id: \.photoAssetIdentifier) { imageModel in
                    UnidentifiedImageGridItem(
                        imageModel: imageModel,
                        isSelected: viewModel.selectedImages.contains(imageModel.photoAssetIdentifier),
                        isSelecting: viewModel.isSelecting
                    ) {
                        if viewModel.isSelecting {
                            viewModel.toggleSelection(for: imageModel.photoAssetIdentifier)
                        } else {
                            // Navigate to detail view
                            selectedImageForDetail = imageModel
                            showingImageDetail = true
                        }
                    }
                }
            }
            .padding(.horizontal, 2)
            .padding(.bottom, 20)
        }
        .overlay(
            // Processing overlay
            Group {
                if viewModel.isProcessing {
                    processingOverlay
                }
            }
        )
    }
    
    private var processingOverlay: some View {
        VStack(spacing: 16) {
            ProgressView(value: viewModel.processingProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: .teal))
                .frame(width: 200)
            
            Text("Processing images...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("\(Int(viewModel.processingProgress * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}

struct UnidentifiedImageGridItem: View {
    let imageModel: UnidentifiedImageModel
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
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .overlay(
                                ProgressView()
                                    .scaleEffect(0.8)
                            )
                    } else if let uiImage = uiImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                                    .font(.title2)
                            )
                    }
                }
                .clipped()
                
                // Selection overlay
                if isSelecting {
                    VStack {
                        HStack {
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(isSelected ? Color.teal : Color.white)
                                    .frame(width: 24, height: 24)
                                    .shadow(radius: 2)
                                
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(8)
                        
                        Spacer()
                    }
                }
                
                // Processed indicator
                if imageModel.isProcessed {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title3)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .padding(8)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            loadImage()
        }
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
        requestOptions.deliveryMode = .fastFormat
        
        let targetSize = CGSize(width: 300, height: 300)
        
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { image, _ in
            DispatchQueue.main.async {
                self.uiImage = image
                self.isLoading = false
            }
        }
    }
}

#Preview {
    UnidentifiedImagesView(path: .constant([]))
        .modelContainer(for: UnidentifiedImageModel.self, inMemory: true)
}
