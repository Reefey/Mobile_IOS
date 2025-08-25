import SwiftUI

// MARK: - Collection Detail View
struct CollectionDetailView: View {
    let collection: Collection
    @State private var selectedTab = 0
    @State private var showingImageDetail = false
    @State private var selectedImageIndex = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header with main image
                headerSection
                    .frame(height: min(geometry.size.height * 0.4, 300))

                // Tab selection
                tabSelectionView
                
                // Content based on selected tab
                if selectedTab == 0 {
                    collectionGalleryView
                } else {
                    infoView
                }
                
                Spacer()
            }
        }
        .navigationTitle(collection.species)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    // Navigation will be handled by NavigationStack
                }
                .foregroundColor(.primary)
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
                    Image("tuna")
                        .resizable()
                        .scaledToFill()
                }
                .clipped()
            } else {
                Image("tuna")
                    .resizable()
                    .scaledToFill()
                    .clipped()
            }
            
            // Gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Collection info overlay
            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(collection.species)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(collection.scientificName)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .italic()
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(collection.totalPhotos) photos")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(collection.firstSeenDate?.formatted(date: .abbreviated, time: .omitted) ?? collection.firstSeen)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding()
            }
        }
    }
    
    private var tabSelectionView: some View {
        HStack(spacing: 0) {
            TabButton(
                title: "Photos",
                isSelected: selectedTab == 0,
                action: { withAnimation(.easeInOut(duration: 0.2)) { selectedTab = 0 } }
            )
            
            TabButton(
                title: "Info",
                isSelected: selectedTab == 1,
                action: { withAnimation(.easeInOut(duration: 0.2)) { selectedTab = 1 } }
            )
        }
        .padding(.horizontal, 20)
        .background(.ultraThinMaterial)
    }
    
    private var collectionGalleryView: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3),
                spacing: 2
            ) {
                ForEach(collection.photos.indices, id: \.self) { index in
                    CollectionPhotoView(photo: collection.photos[index])
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
    
    private var sizeText: String {
        if let minSize = collection.sizeMinCm, let maxSize = collection.sizeMaxCm {
            if minSize == maxSize {
                return "\(Int(minSize)) cm"
            } else {
                return "\(Int(minSize))-\(Int(maxSize)) cm"
            }
        } else {
            return "Unknown"
        }
    }
    
    @ViewBuilder
    private var infoView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Basic Information
                InfoSectionView(title: "Basic Information", content: [
                    ("Scientific Name", collection.scientificName),
                    ("Category", "Marine Species"),
                    ("Rarity", "\(collection.rarity)"),
                    ("Size", sizeText),
                    ("Diet", collection.diet ?? "Unknown"),
                    ("Behavior", collection.behavior ?? "Unknown")
                ])
                
                // Habitat Information
                InfoSectionView(title: "Habitat", content: [
                    ("Habitat Type", collection.habitatType.joined(separator: ", ")),
                    ("Description", collection.description)
                ])
                
                // Sightings
                InfoSectionView(title: "Sightings", content: [
                    ("Total Photos", "\(collection.totalPhotos)"),
                                    ("First Seen", collection.firstSeenDate?.formatted(date: .abbreviated, time: .omitted) ?? collection.firstSeen),
                ("Last Seen", collection.lastSeenDate?.formatted(date: .abbreviated, time: .omitted) ?? collection.lastSeen),
                    ("Status", collection.status)
                ])
            }
            .padding(20)
        }
        .background(Color(UIColor.systemBackground))
    }
    
}

// MARK: - Supporting Views
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(isSelected ? Color.teal : Color.clear)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

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
        .aspectRatio(1, contentMode: .fit)
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
                    
                    Text(photo.dateFoundDate?.formatted(date: .abbreviated, time: .omitted) ?? photo.dateFound)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.7)
                }
                .padding(4)
            )
    }
}

struct InfoSectionView: View {
    let title: String
    let content: [(String, String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(content, id: \.0) { item in
                    HStack(alignment: .top) {
                        Text(item.0)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 120, alignment: .leading)
                        
                        Text(item.1)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

struct ImageDetailView: View {
    let photos: [CollectionPhoto]
    @Binding var selectedIndex: Int
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedIndex) {
                ForEach(photos.indices, id: \.self) { index in
                    ZStack {
                        AsyncImage(url: URL(string: photos[index].url)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding()
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
        deviceId: "device123",
        marineId: 123,
        species: "Clownfish",
        scientificName: "Amphiprion ocellaris",
        rarity: 2,
        sizeMinCm: 6.0,
        sizeMaxCm: 11.0,
        habitatType: ["Coral Reefs", "Anemones"],
        diet: "Omnivore",
        behavior: "Social",
        description: "The iconic clownfish, known for its bright orange color with white stripes.",
        marineImageUrl: nil,
        photos: [
            CollectionPhoto(
                id: 1,
                url: "https://example.com/photo1.jpg",
                annotatedUrl: nil,
                dateFound: "2025-08-25T07:24:24.45+00:00",
                spotId: 1,
                confidence: 0.95,
                boundingBox: nil,
                spots: nil
            )
        ],
        totalPhotos: 1,
                        firstSeen: "2025-08-25T07:24:24.367+00:00",
                lastSeen: "2025-08-25T07:24:24.367+00:00",
        status: "identified"
    )
    
    CollectionDetailView(collection: sampleCollection)
}
