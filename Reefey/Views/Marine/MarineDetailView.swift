import SwiftUI

struct MarineDetailView: View {
    let species: MarineSpecies
    @State private var viewModel = MarineViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Image
                headerImage
                
                // Basic Info
                basicInfoSection
                
                // Physical Characteristics
                physicalCharacteristicsSection
                
                // Behavior & Habitat
                behaviorHabitatSection
                
                // Conservation
                conservationSection
                
                // Fun Facts
                funFactSection
                
                // Found At Spots
                if let spots = species.foundAtSpots, !spots.isEmpty {
                    foundAtSpotsSection(spots: spots)
                } else {
                    noSpotsSection
                }
            }
            .padding()
        }
        .navigationTitle(species.name)
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Header Image
    private var headerImage: some View {
        Group {
            if let imageURL = species.imageUrl {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    // Use thumbnail asset as placeholder
                    let assetName = ThumbnailMapper.getThumbnailAssetName(for: species.scientificName) ?? ThumbnailMapper.getDefaultThumbnailAssetName()
                    Image(assetName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "fish")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                        )
                }
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                // Use thumbnail asset when no image URL
                let assetName = ThumbnailMapper.getThumbnailAssetName(for: species.scientificName) ?? ThumbnailMapper.getRandomThumbnailAssetName()
                Image(assetName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .overlay(
                        Image(systemName: "fish")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                    )
            }
        }
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Basic Information")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                InfoRow(title: "Scientific Name", value: species.scientificName, isItalic: true)
                InfoRow(title: "Category", value: species.category)
                InfoRow(title: "Rarity", value: "\(species.rarity) - \(viewModel.rarityText(for: species.rarity))")
                InfoRow(title: "Danger Level", value: species.danger)
                if species.venomous {
                    InfoRow(title: "Venomous", value: "Yes", color: .red)
                }
            }
        }
    }
    
    // MARK: - Physical Characteristics Section
    private var physicalCharacteristicsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Physical Characteristics")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                InfoRow(title: "Size", value: viewModel.sizeText(for: species))
                if let lifeSpan = species.lifeSpan {
                    InfoRow(title: "Lifespan", value: lifeSpan)
                }
                if let diet = species.diet {
                    InfoRow(title: "Diet", value: diet)
                }
            }
        }
    }
    
    // MARK: - Behavior & Habitat Section
    private var behaviorHabitatSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Behavior & Habitat")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                if let behavior = species.behavior {
                    InfoRow(title: "Behavior", value: behavior)
                }
                InfoRow(title: "Habitat", value: viewModel.habitatText(for: species))
                if let migration = species.migration {
                    InfoRow(title: "Migration", value: migration)
                }
                if let reproduction = species.reproduction {
                    InfoRow(title: "Reproduction", value: reproduction)
                }
            }
        }
    }
    
    // MARK: - Conservation Section
    private var conservationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Conservation")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                if let endangered = species.endangered {
                    InfoRow(title: "Status", value: endangered)
                }
            }
        }
    }
    
    // MARK: - Fun Fact Section
    private var funFactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let funFact = species.funFact {
                Text("Fun Fact")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(funFact)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Found At Spots Section
    private func foundAtSpotsSection(spots: [MarineSpot]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Found At Spots")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(spots, id: \.spotId) { spot in
                SpotCard(spot: spot)
            }
        }
    }
    
    // MARK: - No Spots Section
    private var noSpotsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Found At Spots")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("No spot information available for this species")
                .font(.body)
                .foregroundColor(.secondary)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let title: String
    let value: String
    var isItalic: Bool = false
    var color: Color = .primary
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(color)
                .italic(isItalic)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
}

// MARK: - Spot Card
struct SpotCard: View {
    let spot: MarineSpot
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Spot #\(spot.spotId)")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Frequency: \(spot.frequency)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Seasonality: \(spot.seasonality)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            if let notes = spot.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    NavigationView {
        MarineDetailView(species: MarineSpecies(
            id: 1,
            name: "Clownfish",
            scientificName: "Amphiprion ocellaris",
            category: "Fishes",
            rarity: 2,
            sizeMinCm: 6.0,
            sizeMaxCm: 11.0,
            habitatType: ["Coral Reefs", "Anemones"],
            diet: "Plankton, small inverts, algae",
            behavior: "Social",
            danger: "Low",
            venomous: false,
            description: "The iconic clownfish, known for its bright orange color with white stripes.",
            imageUrl: nil,
            lifeSpan: "6-10 years",
            reproduction: "Eggs near anemone; male guards",
            migration: "Site-attached to host",
            endangered: "Least Concern",
            funFact: "Sequential hermaphrodites - can change sex from male to female",
            foundAtSpots: [
                MarineSpot(
                    spotId: 1,
                    frequency: "Common",
                    seasonality: "Year-round",
                    notes: "Found near anemones in shallow waters"
                )
            ],
            totalSpots: 1
        ))
    }
}
