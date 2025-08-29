import SwiftUI

struct MarineListView: View {
    @State private var viewModel = MarineViewModel()
    @State private var showingFilters = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Filter Chips
                filterChips
                
                // Content
                if viewModel.isLoading && viewModel.marineSpecies.isEmpty {
                    loadingView
                } else if viewModel.marineSpecies.isEmpty {
                    emptyStateView
                } else {
                    marineList
                }
            }
            .navigationTitle("Marine Species")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    filterButton
                }
            }
            .sheet(isPresented: $showingFilters) {
                MarineFilterView(viewModel: viewModel)
            }
            .refreshable {
                await viewModel.loadMarineSpecies(refresh: true)
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search marine species...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit {
                    viewModel.searchText = searchText
                    Task {
                        await viewModel.searchMarineSpecies()
                    }
                }
            
            if !searchText.isEmpty {
                Button("Clear") {
                    searchText = ""
                    viewModel.searchText = ""
                    Task {
                        await viewModel.searchMarineSpecies()
                    }
                }
                .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    // MARK: - Filter Chips
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Category Filter
                if viewModel.selectedCategory != "ALL" {
                    FilterChip(
                        title: viewModel.selectedCategory,
                        color: viewModel.categoryColor(for: viewModel.selectedCategory)
                    ) {
                        Task {
                            await viewModel.selectCategory("ALL")
                        }
                    }
                }
                
                // Rarity Filter
                if let rarity = viewModel.selectedRarity {
                    FilterChip(
                        title: "Rarity: \(viewModel.rarityText(for: rarity))",
                        color: .purple
                    ) {
                        Task {
                            await viewModel.selectRarity(nil)
                        }
                    }
                }
                
                // Danger Filter
                if viewModel.selectedDanger != "ALL" {
                    FilterChip(
                        title: "Danger: \(viewModel.selectedDanger)",
                        color: viewModel.dangerColor(for: viewModel.selectedDanger)
                    ) {
                        Task {
                            await viewModel.selectDanger("ALL")
                        }
                    }
                }
                
                // Clear All Filters
                if viewModel.selectedCategory != "ALL" || 
                   viewModel.selectedRarity != nil || 
                   viewModel.selectedDanger != "ALL" {
                    FilterChip(
                        title: "Clear All",
                        color: .gray
                    ) {
                        Task {
                            await viewModel.clearFilters()
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Marine List
    private var marineList: some View {
        List {
            ForEach(viewModel.marineSpecies) { species in
                MarineSpeciesRow(species: species)
                    .onAppear {
                        if species.id == viewModel.marineSpecies.last?.id && viewModel.hasMoreData {
                            Task {
                                await viewModel.loadMarineSpecies()
                            }
                        }
                    }
            }
            
            if viewModel.isLoading && !viewModel.marineSpecies.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding()
                    Spacer()
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("Loading marine species...")
                .scaleEffect(1.2)
            Spacer()
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(ThumbnailMapper.getDefaultThumbnailAssetName())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.gray.opacity(0.6))
            
            Text("No marine species found")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Try adjusting your filters or search terms")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Clear Filters") {
                Task {
                    await viewModel.clearFilters()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    // MARK: - Filter Button
    private var filterButton: some View {
        Button {
            showingFilters = true
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.title2)
        }
    }
}

// MARK: - Marine Species Row
struct MarineSpeciesRow: View {
    let species: MarineSpecies
    @State private var viewModel = MarineViewModel()
    
    var body: some View {
        NavigationLink(destination: MarineDetailView(species: species)) {
            HStack(spacing: 12) {
                // Image or Placeholder
                if let imageURL = species.imageUrl {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "fish")
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "fish")
                                .foregroundColor(.gray)
                        )
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(species.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Rarity Badge
                        Text("\(species.rarity)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(rarityColor(for: species.rarity))
                            .clipShape(Capsule())
                    }
                    
                    Text(species.scientificName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                    
                    HStack {
                        // Category Badge
                        Text(species.category)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(viewModel.categoryColor(for: species.category).opacity(0.2))
                            .foregroundColor(viewModel.categoryColor(for: species.category))
                            .clipShape(Capsule())
                        
                        // Danger Badge
                        Text(species.danger)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(viewModel.dangerColor(for: species.danger).opacity(0.2))
                            .foregroundColor(viewModel.dangerColor(for: species.danger))
                            .clipShape(Capsule())
                        
                        Spacer()
                        
                        // Size
                        Text(viewModel.sizeText(for: species))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private func rarityColor(for rarity: Int) -> Color {
        switch rarity {
        case 1: return .green
        case 2: return .blue
        case 3: return .yellow
        case 4: return .orange
        case 5: return .red
        default: return .gray
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let color: Color
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .foregroundColor(color)
        .clipShape(Capsule())
    }
}

#Preview {
    MarineListView()
}
