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
            if let imageURL = species.marineImage {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
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
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
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
                InfoRow(title: "Lifespan", value: species.lifeSpan)
                InfoRow(title: "Diet", value: species.diet)
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
                InfoRow(title: "Behavior", value: species.behavior)
                InfoRow(title: "Habitat", value: viewModel.habitatText(for: species))
                InfoRow(title: "Migration", value: species.migration)
                InfoRow(title: "Reproduction", value: species.reproduction)
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
                InfoRow(title: "Status", value: species.endangered)
            }
        }
    }
    
    // MARK: - Fun Fact Section
    private var funFactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fun Fact")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(species.funFact)
                .font(.body)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
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
            Text(spot.spotName)
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
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Lat: \(String(format: "%.4f", spot.lat))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Lng: \(String(format: "%.4f", spot.lng))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
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
            marineImage: nil,
            lifeSpan: "6-10 years",
            reproduction: "Eggs near anemone; male guards",
            migration: "Site-attached to host",
            endangered: "Least Concern",
            funFact: "Sequential hermaphrodites - can change sex from male to female",
            foundAtSpots: [
                MarineSpot(
                    spotId: 1,
                    spotName: "Menjangan Island",
                    lat: -8.1526,
                    lng: 114.5139,
                    frequency: "Common",
                    seasonality: "Year-round",
                    notes: "Found near anemones in shallow waters"
                )
            ],
            totalSpots: 1
        ))
    }
}
