//
//  UnidentifiedImageFullView.swift
//  Reefey
//
//  Created by Reza Juliandri on 28/08/25.
//


import SwiftUI
import SwiftData
import Photos

struct UnidentifiedImageFullView: View {
    let imageModel: UnidentifiedImageModel
    @State private var uiImage: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipped()
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .onAppear {
            loadFullImage()
        }
    }
    
    private func loadFullImage() {
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
        
        imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions) { image, _ in
            DispatchQueue.main.async {
                self.uiImage = image
                self.isLoading = false
            }
        }
    }
}

#Preview {
    UnidentifiedImageFullView(
        imageModel: UnidentifiedImageModel(
            photoAssetIdentifier: "",
            dateTaken: Date(),
            isProcessed: false
        )
    )
}
