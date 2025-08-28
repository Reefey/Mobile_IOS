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
    
    @State private var isSelectButtonTapped: Bool = false
    
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
            VStack {
                Spacer()
                    .frame(height: 30)
                HStack {
                    Spacer()
                    Button {
                        isSelectButtonTapped.toggle()
                    } label: {
                        Text(isSelectButtonTapped == true ? "Cancel" : "Select")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray.opacity(0.9))
                    }
                    .padding(.vertical, 3)
                    .padding(.horizontal, 10)
                    .buttonStyle(PlainButtonStyle())
                    .background(.ultraThickMaterial)
                    .cornerRadius(10)
                    Spacer()
                        .frame(width: 20)
                }.padding()
                Spacer()
            }
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

#Preview {
    CollectionToBeIdentifiedView()
        .modelContainer(for: UnidentifiedImageModel.self, inMemory: true)
}
