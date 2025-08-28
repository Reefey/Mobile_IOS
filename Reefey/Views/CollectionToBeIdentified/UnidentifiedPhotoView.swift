//
//  UnidentifiedPhotoView.swift
//  Reefey
//
//  Created by Reza Juliandri on 28/08/25.
//


import SwiftUI
import SwiftData
import Photos

struct UnidentifiedPhotoView: View {
    let imageModel: UnidentifiedImageModel
    @State private var uiImage: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.1))
            } else if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                photoPlaceholder
            }
        }
        .frame(width: 140, height: 140)
        .clipped()
        .background(Color.gray.opacity(0.1))
        .onAppear {
            loadImage()
        }
    }
    
    private var photoPlaceholder: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .overlay(
                VStack(spacing: 4) {
                    Image(systemName: "photo")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    
                    Text("Photo")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            )
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
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: requestOptions) { image, _ in
            DispatchQueue.main.async {
                self.uiImage = image
                self.isLoading = false
            }
        }
    }
}


#Preview {
    UnidentifiedPhotoView(imageModel:
        UnidentifiedImageModel(
            photoAssetIdentifier: "",
            dateTaken: Date(),
            isProcessed: false
        )
    )
}
