import SwiftUI
import SwiftData
import Photos

// MARK: - Collection To Be Identified View
struct CollectionToBeIdentifiedView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UnidentifiedImageModel.dateTaken, order: .reverse) private var unidentifiedImages: [UnidentifiedImageModel]
    
    @State private var showingImageDetail = false
    @State private var selectedImageIndex = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with main image
            headerSection
            
            // Content based on selected tab
            collectionGalleryView
        }
        .ignoresSafeArea(edges: .top)
        .fullScreenCover(isPresented: $showingImageDetail) {
            UnidentifiedImageDetailView(
                images: unidentifiedImages,
                selectedIndex: $selectedImageIndex,
                isPresented: $showingImageDetail
            )
        }
    }
    
    private var headerSection: some View {
        ZStack {
            headerPlaceholder
        }
        .frame(maxHeight: 300)
        .clipped()
    }
    
    private var headerPlaceholder: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.gray.opacity(0.4), .gray.opacity(0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                Image(systemName: "fish.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.6))
            )
    }
    
    private var collectionGalleryView: some View {
        GeometryReader { geometry in
            let itemSize = (geometry.size.width - 8) / 3 // screen width - total spacing (2px * 4 = 8px)
            
            if unidentifiedImages.isEmpty {
                VStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.6))
                        
                        Text("No photos available")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Text("Photos will appear here once they are added to this collection")
                            .font(.system(size: 14))
                            .foregroundColor(.gray.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    Spacer()
                }
                .background(Color(UIColor.systemBackground))
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.fixed(itemSize), spacing: 2),
                        GridItem(.fixed(itemSize), spacing: 2),
                        GridItem(.fixed(itemSize), spacing: 2)
                    ], spacing: 2) {
                        ForEach(Array(unidentifiedImages.enumerated()), id: \.offset) { index, imageModel in
                            UnidentifiedPhotoView(imageModel: imageModel)
                                .frame(width: itemSize, height: itemSize)
                                .onTapGesture {
                                    selectedImageIndex = index
                                    showingImageDetail = true
                                }
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.top, 2)
                }
                .background(Color(UIColor.systemBackground))
            }
        }
    }
    
    private var collectionInfoSection: some View {
        InfoSectionView(title: "Your Collection", content: [
            ("Total Photos", "\(unidentifiedImages.count)"),
            ("First Seen", unidentifiedImages.last?.dateTaken.formatted(date: .abbreviated, time: .omitted) ?? "Unknown"),
            ("Last Seen", unidentifiedImages.first?.dateTaken.formatted(date: .abbreviated, time: .omitted) ?? "Unknown")
        ])
    }
}

// MARK: - Supporting Views

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

struct UnidentifiedImageDetailView: View {
    let images: [UnidentifiedImageModel]
    @Binding var selectedIndex: Int
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $selectedIndex) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, imageModel in
                    UnidentifiedImageFullView(imageModel: imageModel)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            
            // Navigation overlay
            VStack {
                HStack {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 17, weight: .medium))
                    .padding()
                    
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

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
    CollectionToBeIdentifiedView()
        .modelContainer(for: UnidentifiedImageModel.self, inMemory: true)
}
