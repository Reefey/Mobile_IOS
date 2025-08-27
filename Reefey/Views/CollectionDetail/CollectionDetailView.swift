import SwiftUI

// MARK: - Collection Detail View With Loader
struct CollectionDetailViewWithLoader: View {
    let marineId: Int
    @State private var viewModel = CollectionDetailViewModel()
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView("Loading collection details...")
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#4CAFA1")))
                    Spacer()
                }
            } else if let collection = viewModel.collection {
                CollectionDetailView(collection: collection)
            } else {
                VStack {
                    Spacer()
                    Text("Failed to load collection details")
                        .foregroundColor(.secondary)
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 4)
                    }
                    Button("Retry") {
                        Task {
                            await loadCollectionDetail()
                        }
                    }
                    .padding(.top, 8)
                    Spacer()
                }
            }
        }
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
        .onAppear {
            Task {
                await loadCollectionDetail()
            }
        }
    }
    
    private func loadCollectionDetail() async {
        isLoading = true
        let deviceManager = DeviceManager.shared
        await viewModel.loadCollectionDetail(deviceId: deviceManager.deviceId, id: marineId)
        isLoading = false
    }
}

// MARK: - Collection Detail View
struct CollectionDetailView: View {
    let collection: Collection
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CollectionDetailViewModel()
    
    @State private var selectedTab = 0
    @State private var showingImageDetail = false
    @State private var selectedImageIndex = 0
    @State private var marineSpecies: MarineSpecies?
    @State private var isLoadingMarineData = false
    
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
        .onAppear {
            Task {
                await loadMarineSpeciesData()
            }
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
            } else if let marineSpecies = marineSpecies, let imageURL = marineSpecies.imageUrl {
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
                        ForEach(Array(collection.photos.enumerated()), id: \.offset) { index, photo in
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
                if isLoadingMarineData {
                    VStack {
                        ProgressView("Loading marine data...")
                            .padding()
                    }
                } else if let marineSpecies = marineSpecies {
                    // Comprehensive Marine Species Information
                    basicInfoSection(marineSpecies)
                    physicalCharacteristicsSection(marineSpecies)
                    behaviorHabitatSection(marineSpecies)
                    conservationSection(marineSpecies)
                    funFactSection(marineSpecies)
                    
                    if let spots = marineSpecies.foundAtSpots, !spots.isEmpty {
                        foundAtSpotsSection(spots: spots)
                    }
                } else {
                    // Fallback to collection data only
                    fallbackInfoSection
                }
                
                // Collection-specific information
                collectionInfoSection
            }
            .padding(20)
        }
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - Marine Data Loading
    private func loadMarineSpeciesData() async {
        isLoadingMarineData = true
        
        do {
            let networkService = NetworkService.shared
            let response = try await networkService.fetchMarineSpeciesDetail(id: collection.id)
            if response.success {
                await MainActor.run {
                    marineSpecies = response.data
                }
            }
        } catch {
            print("Failed to load marine species data: \(error.localizedDescription)")
        }
        
        await MainActor.run {
            isLoadingMarineData = false
        }
    }
    
    // MARK: - Info Sections
    private func basicInfoSection(_ species: MarineSpecies) -> some View {
        InfoSectionView(title: "Basic Information", content: [
            ("Species", species.name),
            ("Scientific Name", species.scientificName),
            ("Category", species.category),
            ("Rarity", "\(species.rarity)/5 - \(rarityText(for: species.rarity))"),
            ("Danger Level", species.danger),
            ("Venomous", species.venomous ? "Yes" : "No")
        ])
    }
    
    private func physicalCharacteristicsSection(_ species: MarineSpecies) -> some View {
        var content: [(String, String)] = []
        
        // Handle size
        if let sizeMin = species.sizeMinCm {
            if let sizeMax = species.sizeMaxCm {
                content.append(("Size Range", "\(Int(sizeMin))-\(Int(sizeMax)) cm"))
            } else {
                content.append(("Size Range", "\(Int(sizeMin))+ cm"))
            }
        } else {
            content.append(("Size Range", "Size unknown"))
        }
        
        // Handle lifespan
        if let lifeSpan = species.lifeSpan {
            content.append(("Life Span", lifeSpan))
        }
        
        // Handle habitat
        if species.habitatType.isEmpty {
            content.append(("Habitat Type", "Habitat information not available"))
        } else {
            content.append(("Habitat Type", species.habitatType.joined(separator: ", ")))
        }
        
        return InfoSectionView(title: "Physical Characteristics", content: content)
    }
    
    private func behaviorHabitatSection(_ species: MarineSpecies) -> some View {
        var content: [(String, String)] = []
        
        if let diet = species.diet {
            content.append(("Diet", diet))
        }
        if let behavior = species.behavior {
            content.append(("Behavior", behavior))
        }
        if let migration = species.migration {
            content.append(("Migration", migration))
        }
        if let reproduction = species.reproduction {
            content.append(("Reproduction", reproduction))
        }
        
        return InfoSectionView(title: "Behavior & Habitat", content: content)
    }
    
    private func conservationSection(_ species: MarineSpecies) -> some View {
        var content: [(String, String)] = [
            ("Description", species.description)
        ]
        
        if let endangered = species.endangered {
            content.append(("Endangered Status", endangered))
        }
        
        return InfoSectionView(title: "Conservation", content: content)
    }
    
    private func funFactSection(_ species: MarineSpecies) -> some View {
        if let funFact = species.funFact {
            return AnyView(InfoSectionView(title: "Fun Fact", content: [
                ("Did You Know?", funFact)
            ]))
        } else {
            return AnyView(EmptyView())
        }
    }
    
    private func foundAtSpotsSection(spots: [MarineSpot]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Found At Spots")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(spots, id: \.spotId) { spot in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Spot #\(spot.spotId)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text("Frequency: \(spot.frequency)")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("Season: \(spot.seasonality)")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        if let notes = spot.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var fallbackInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            InfoSectionView(title: "Basic Information", content: [
                ("Species", collection.species),
                ("Scientific Name", collection.scientificName ?? "Unknown"),
                ("Rarity", "\(collection.rarity ?? 0)/5"),
                ("Status", collection.status ?? "Unknown")
            ])
            
            if let minSize = collection.sizeMinCm, let maxSize = collection.sizeMaxCm {
                InfoSectionView(title: "Size", content: [
                    ("Size Range", "\(Int(minSize))-\(Int(maxSize)) cm")
                ])
            }
            
            if let habitatType = collection.habitatType, !habitatType.isEmpty {
                InfoSectionView(title: "Habitat", content: [
                    ("Habitat Type", habitatType.joined(separator: ", "))
                ])
            }
            
            InfoSectionView(title: "Description", content: [
                ("Details", collection.description ?? "No description available")
            ])
        }
    }
    
    private var collectionInfoSection: some View {
        InfoSectionView(title: "Your Collection", content: [
            ("Total Photos", "\(collection.totalPhotos ?? 0)"),
            ("First Seen", collection.firstSeenDate?.formatted(date: .abbreviated, time: .omitted) ?? (collection.firstSeen ?? "Unknown")),
            ("Last Seen", collection.lastSeenDate?.formatted(date: .abbreviated, time: .omitted) ?? (collection.lastSeen ?? "Unknown"))
        ])
    }
    
    // MARK: - Helper Methods
    private func rarityText(for rarity: Int) -> String {
        switch rarity {
        case 1: return "Very Common"
        case 2: return "Common"
        case 3: return "Uncommon"
        case 4: return "Rare"
        case 5: return "Very Rare"
        default: return "Unknown"
        }
    }
    
}

// MARK: - Supporting Views

struct CollectionPhotoView: View {
    let photo: CollectionPhoto
    
    var body: some View {
        Group {
            AsyncImage(url: URL(string: photo.url ?? "")) { image in
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
                ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                    ZStack {
                        AsyncImage(url: URL(string: photo.url ?? "")) { image in
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
        name: "Bluefin Tuna",
        scientificName: "Thunnus thynnus",
        category: "Fishes",
        rarity: 5,
        sizeMinCm: 200,
        sizeMaxCm: 400,
        habitatType: ["Deep Ocean", "Open Water"],
        diet: "Fish and squid",
        behavior: "Fast swimming predator",
        danger: "High",
        venomous: false,
        description: "A large, fast-swimming fish found in the Atlantic Ocean and Mediterranean Sea.",
        lifeSpan: "15-20 years",
        reproduction: "Spawning in warm waters",
        migration: "Long-distance migration",
        endangered: "Critically Endangered",
        funFact: "Can swim up to 70 km/h",
        imageUrl: nil,
        createdAt: "2025-01-01T00:00:00Z",
        updatedAt: "2025-08-20T15:30:00Z",
        inUserCollection: true,
        hasAnalyzedPhotos: true,
        lastSeen: "2025-08-20T15:30:00Z",
        firstSeen: "2025-01-15T10:00:00Z",
        totalPhotos: 15,
        userPhotos: [],
        collectionId: 157,
        status: "identified"
    )
    
    CollectionDetailView(collection: sampleCollection)
}
