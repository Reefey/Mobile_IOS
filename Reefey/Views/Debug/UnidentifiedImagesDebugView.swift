//
//  UnidentifiedImagesDebugView.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//

import SwiftUI
import SwiftData
import Photos

struct UnidentifiedImagesDebugView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \UnidentifiedImageModel.dateTaken, order: .reverse) private var unidentifiedImages: [UnidentifiedImageModel]
    
    var body: some View {
        NavigationView {
            List {
                if unidentifiedImages.isEmpty {
                    ContentUnavailableView {
                        Label("No Unidentified Images", systemImage: "photo.stack")
                    } description: {
                        Text("Take photos in locked camera mode to see them here.")
                    }
                } else {
                    ForEach(unidentifiedImages, id: \.photoAssetIdentifier) { imageModel in
                        UnidentifiedImageRow(imageModel: imageModel)
                    }
                    .onDelete(perform: deleteImages)
                }
            }
            .navigationTitle("Debug: Unidentified Images")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear All") {
                        clearAllImages()
                    }
                    .foregroundColor(.red)
                    .disabled(unidentifiedImages.isEmpty)
                }
            }
        }
    }
    
    private func deleteImages(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(unidentifiedImages[index])
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Error deleting images: \(error)")
            }
        }
    }
    
    private func clearAllImages() {
        withAnimation {
            for image in unidentifiedImages {
                modelContext.delete(image)
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Error clearing all images: \(error)")
            }
        }
    }
}

struct UnidentifiedImageRow: View {
    let imageModel: UnidentifiedImageModel
    @State private var uiImage: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        HStack {
            // Image preview
            Group {
                if isLoading {
                    ProgressView()
                        .frame(width: 60, height: 60)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                } else if let uiImage = uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                        .frame(width: 60, height: 60)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Asset ID:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(imageModel.photoAssetIdentifier)
                    .font(.system(.caption, design: .monospaced))
                    .lineLimit(2)
                
                Text("Date Taken:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(imageModel.dateTaken, style: .date)
                    .font(.caption)
                
                Text(imageModel.dateTaken, style: .time)
                    .font(.caption)
                
                HStack {
                    Text("Processed:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Image(systemName: imageModel.isProcessed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(imageModel.isProcessed ? .green : .gray)
                        .font(.caption)
                }
            }
            
            Spacer()
        }
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
        requestOptions.deliveryMode = .highQualityFormat
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 120, height: 120), contentMode: .aspectFill, options: requestOptions) { image, _ in
            DispatchQueue.main.async {
                self.uiImage = image
                self.isLoading = false
            }
        }
    }
}

#Preview {
    UnidentifiedImagesDebugView()
        .modelContainer(for: UnidentifiedImageModel.self, inMemory: true)
}