import SwiftUI

// MARK: - Collection Detail View
struct CollectionDetailView: View {
    let collection: Collection
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTab = 0
    @State private var showingImageDetail = false
    @State private var selectedImageIndex = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with main image
            headerSection

            // Tab selection
            tabSelectionView
            
            // Content based on selected tab
            if selectedTab == 0 {
                collectionGalleryView
            } else {
                infoView
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .fullScreenCover(isPresented: $showingImageDetail) {
            ImageDetailView(
                photos: collection.photos,
                selectedIndex: $selectedImageIndex,
                isPresented: $showingImageDetail
            )
        }
    }
    
    private var headerSection: some View {
        ZStack {
            // Main header image
            if let imageURL = collection.marineImageUrl {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    headerPlaceholder
                }
            } else {
                headerPlaceholder
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
    
    private var tabSelectionView: some View {
        VStack {
            Picker("Tab Selection", selection: $selectedTab) {
                Text("Collection").tag(0)
                Text("Info").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onAppear {
                // Change the selected segment background color
                UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color(hex: "#0FAAAC"))
                // Optionally change the overall background
                UISegmentedControl.appearance().backgroundColor = UIColor(Color(hex: "#e0fffb"))
                
                // Change text colors
                UISegmentedControl.appearance().setTitleTextAttributes([
                    .foregroundColor: UIColor.label
                ], for: .normal)
                UISegmentedControl.appearance().setTitleTextAttributes([
                    .foregroundColor: UIColor.white
                ], for: .selected)
            }
            .padding(.horizontal, 20)
        }.padding()
    }
    
    private var collectionGalleryView: some View {
        GeometryReader { geometry in
            let itemSize = (geometry.size.width - 8) / 3 // screen width - total spacing (2px * 4 = 8px)
            
            if collection.photos.isEmpty {
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
                        ForEach(Array(collection.photos.enumerated()), id: \.element.id) { index, photo in
                            CollectionPhotoView(photo: photo)
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
    
    @ViewBuilder
    private var infoView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                InfoSectionView(title: "Basic Information", content: [
                    ("Species", collection.species),
                    ("Scientific Name", collection.scientificName),
                    ("Rarity", "\(collection.rarity)/5"),
                    ("Status", collection.status)
                ])
                
                if let minSize = collection.sizeMinCm, let maxSize = collection.sizeMaxCm {
                    InfoSectionView(title: "Size", content: [
                        ("Size Range", "\(Int(minSize))-\(Int(maxSize)) cm")
                    ])
                }
                
                if !collection.habitatType.isEmpty {
                    InfoSectionView(title: "Habitat", content: [
                        ("Habitat Type", collection.habitatType.joined(separator: ", "))
                    ])
                }
                
                InfoSectionView(title: "Description", content: [
                    ("Details", collection.description)
                ])
                
                InfoSectionView(title: "Sightings", content: [
                    ("Total Photos", "\(collection.totalPhotos)"),
                    ("First Seen", collection.firstSeenDate?.formatted(date: .abbreviated, time: .omitted) ?? collection.firstSeen),
                    ("Last Seen", collection.lastSeenDate?.formatted(date: .abbreviated, time: .omitted) ?? collection.lastSeen)
                ])
            }
            .padding(20)
        }
        .background(Color(UIColor.systemBackground))
    }
    
}

// MARK: - Supporting Views

struct CollectionPhotoView: View {
    let photo: CollectionPhoto
    
    var body: some View {
        Group {
            AsyncImage(url: URL(string: photo.url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                photoPlaceholder
            }
        }
        .clipped()
        .background(Color.gray.opacity(0.1))
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
}

struct InfoSectionView: View {
    let title: String
    let content: [(String, String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(content, id: \.0) { item in
                    HStack(alignment: .top) {
                        Text(item.0)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 100, alignment: .leading)
                        
                        Text(item.1)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct ImageDetailView: View {
    let photos: [CollectionPhoto]
    @Binding var selectedIndex: Int
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedIndex) {
                ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                    ZStack {
                        AsyncImage(url: URL(string: photo.url)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .onTapGesture {
                                    isPresented = false
                                }
                        } placeholder: {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
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



#Preview {
    let sampleCollection = Collection(
        id: 1,
        deviceId: "sample-device",
        marineId: 123,
        species: "Bluefin Tuna",
        scientificName: "Thunnus thynnus",
        rarity: 5,
        sizeMinCm: 200,
        sizeMaxCm: 400,
        habitatType: ["Deep Ocean", "Open Water"],
        diet: "Fish and squid",
        behavior: "Fast swimming predator",
        description: "A large, fast-swimming fish found in the Atlantic Ocean and Mediterranean Sea.",
        marineImageUrl: nil,
        photos: [],
        totalPhotos: 15,
        firstSeen: "2025-01-15T10:00:00Z",
        lastSeen: "2025-08-20T15:30:00Z",
        status: "Endangered"
    )
    
    CollectionDetailView(collection: sampleCollection)
}
