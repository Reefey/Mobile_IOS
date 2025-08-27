import SwiftUI

// MARK: - Collection Detail View
struct CollectionDetailView: View {
    let collection: MarineSpecies
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CollectionDetailViewModel()
    @State private var selectedTab = 0
    @State private var showingImageDetail = false
    @State private var selectedImageIndex = 0
    
    private var sizeText: String {
        guard let sizeMin = collection.sizeMinCm,
              let sizeMax = collection.sizeMaxCm else {
            return "Size unknown"
        }
        
        if sizeMin == sizeMax {
            return "\(sizeMin) cm"
        } else {
            return "\(sizeMin)-\(sizeMax) cm"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header Section
                headerSection
                
                // Tab Selection
                tabSelectionView
                
                // Content based on selected tab
                if selectedTab == 0 {
                    collectionInfoView
                } else {
                    marineSpeciesInfoView
                }
            }
        }
        .navigationTitle(collection.name)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(false)
    }
    
    private var headerSection: some View {
        ZStack {
            if let imageURL = collection.imageUrl {
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
            .padding(.horizontal, 20)
        }.padding()
    }
    
    private var collectionInfoView: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Basic Info
            VStack(alignment: .leading, spacing: 12) {
                Text("Collection Information")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(spacing: 8) {
                    InfoRow(title: "Name", value: collection.name)
                    InfoRow(title: "Scientific Name", value: collection.scientificName, isItalic: true)
                    InfoRow(title: "Category", value: collection.category)
                    InfoRow(title: "Rarity", value: "\(collection.rarity)")
                    InfoRow(title: "Danger Level", value: collection.danger)
                    if collection.venomous {
                        InfoRow(title: "Venomous", value: "Yes", color: .red)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Photos Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Photos")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 20)
                
                if collection.userPhotos.isEmpty {
                    VStack {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 48))
                                .foregroundColor(.gray.opacity(0.6))
                            
                            Text("No photos available")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                            
                            Text("Photos will appear here when available")
                                .font(.system(size: 14))
                                .foregroundColor(.gray.opacity(0.8))
                        }
                        .padding(.vertical, 40)
                        Spacer()
                    }
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                        ForEach(Array(collection.userPhotos.enumerated()), id: \.element.id) { index, photo in
                            AsyncImage(url: URL(string: photo.url)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 120)
                                    .clipped()
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        selectedImageIndex = index
                                        showingImageDetail = true
                                    }
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 120)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    private var marineSpeciesInfoView: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Physical Characteristics
            VStack(alignment: .leading, spacing: 12) {
                Text("Physical Characteristics")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(spacing: 8) {
                    InfoRow(title: "Size", value: sizeText)
                    InfoRow(title: "Lifespan", value: collection.lifeSpan ?? "Unknown")
                    InfoRow(title: "Diet", value: collection.diet ?? "Unknown")
                }
            }
            .padding(.horizontal, 20)
            
            // Behavior & Habitat
            VStack(alignment: .leading, spacing: 12) {
                Text("Behavior & Habitat")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(spacing: 8) {
                    InfoRow(title: "Behavior", value: collection.behavior ?? "Unknown")
                    InfoRow(title: "Habitat", value: collection.habitatType.isEmpty ? "Unknown" : collection.habitatType.joined(separator: ", "))
                    InfoRow(title: "Migration", value: collection.migration ?? "Unknown")
                    InfoRow(title: "Reproduction", value: collection.reproduction ?? "Unknown")
                }
            }
            .padding(.horizontal, 20)
            
            // Conservation
            VStack(alignment: .leading, spacing: 12) {
                Text("Conservation")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(spacing: 8) {
                    InfoRow(title: "Status", value: collection.endangered ?? "Unknown")
                }
            }
            .padding(.horizontal, 20)
            
            // Fun Fact
            VStack(alignment: .leading, spacing: 12) {
                Text("Fun Fact")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(collection.funFact ?? "No fun fact available")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 20)
        }
    }
}



#Preview {
    let sampleCollection = MarineSpecies(
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
        danger: "Low",
        venomous: false,
        description: "A large, fast-swimming fish found in the Atlantic Ocean and Mediterranean Sea.",
        lifeSpan: "20-30 years",
        reproduction: "Egg-laying",
        migration: "Long-distance",
        endangered: "Endangered",
        funFact: "Can swim at speeds up to 75 km/h",
        imageUrl: nil,
        createdAt: "2025-01-15T10:00:00Z",
        updatedAt: "2025-08-20T15:30:00Z",
        inUserCollection: false,
        hasAnalyzedPhotos: false,
        totalPhotos: 0,
        userPhotos: []
    )
    
    CollectionDetailView(collection: sampleCollection)
}
