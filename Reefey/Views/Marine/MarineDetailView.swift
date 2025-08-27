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
                
                // User Photos
                if !species.userPhotos.isEmpty {
                    userPhotosSection
                } else {
                    noPhotosSection
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
                InfoRow(title: "Lifespan", value: species.lifeSpan ?? "Unknown")
                InfoRow(title: "Diet", value: species.diet ?? "Unknown")
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
                InfoRow(title: "Behavior", value: species.behavior ?? "Unknown")
                InfoRow(title: "Habitat", value: species.habitatType.isEmpty ? "Unknown" : species.habitatType.joined(separator: ", "))
                InfoRow(title: "Migration", value: species.migration ?? "Unknown")
                InfoRow(title: "Reproduction", value: species.reproduction ?? "Unknown")
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
                InfoRow(title: "Status", value: species.endangered ?? "Unknown")
            }
        }
    }
    
    // MARK: - Fun Fact Section
    private var funFactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fun Fact")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(species.funFact ?? "No fun fact available")
                .font(.body)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    // MARK: - User Photos Section
    private var userPhotosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("User Photos")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("\(species.totalPhotos) photos")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - No Photos Section
    private var noPhotosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("User Photos")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("No photos available for this species")
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

#Preview {
    NavigationView {
        MarineDetailView(species: MarineSpecies(
            id: 1,
            name: "Clownfish",
            scientificName: "Amphiprion ocellaris",
            category: "Fishes",
            rarity: 2,
            sizeMinCm: 6,
            sizeMaxCm: 11,
            habitatType: ["Coral Reefs", "Anemones"],
            diet: "Plankton, small inverts, algae",
            behavior: "Social",
            danger: "Low",
            venomous: false,
            description: "The iconic clownfish, known for its bright orange color with white stripes.",
            lifeSpan: "6-10 years",
            reproduction: "Eggs near anemone; male guards",
            migration: "Site-attached to host",
            endangered: "Least Concern",
            funFact: "Sequential hermaphrodites - can change sex from male to female",
            imageUrl: nil,
            createdAt: "2025-01-01T00:00:00.000Z",
            updatedAt: "2025-01-01T00:00:00.000Z",
            inUserCollection: false,
            hasAnalyzedPhotos: false,
            totalPhotos: 0,
            userPhotos: []
        ))
    }
}
